use std::path::PathBuf;

use anyhow::Result;
use structopt::StructOpt;

use filter::{
    matcher::{Algo, Bonus, MatchType},
    subprocess, FilterContext, Source,
};
use source_item::SourceItem;

use crate::app::Params;

fn parse_bonus(s: &str) -> Bonus {
    if s.to_lowercase().as_str() == "filename" {
        Bonus::FileName
    } else {
        Bonus::None
    }
}

/// Execute the shell command
#[derive(StructOpt, Debug, Clone)]
pub struct Filter {
    /// Initial query string
    #[structopt(index = 1, short, long)]
    query: String,

    /// Filter algorithm
    #[structopt(short, long, possible_values = &Algo::variants(), case_insensitive = true)]
    algo: Option<Algo>,

    /// Shell command to produce the whole dataset that query is applied on.
    #[structopt(short, long)]
    cmd: Option<String>,

    /// Working directory of shell command.
    #[structopt(short, long)]
    cmd_dir: Option<String>,

    /// Recently opened file list for adding a bonus to the initial score.
    #[structopt(long, parse(from_os_str))]
    recent_files: Option<PathBuf>,

    /// Read input from a file instead of stdin, only absolute file path is supported.
    #[structopt(long, parse(from_os_str))]
    input: Option<PathBuf>,

    /// Apply the filter on the full line content or parial of it.
    #[structopt(short, long, possible_values = &MatchType::variants(), case_insensitive = true)]
    match_type: Option<MatchType>,

    /// Add a bonus to the score of base matching algorithm.
    #[structopt(short, long, parse(from_str = parse_bonus))]
    bonus: Option<Bonus>,

    /// Synchronous filtering, returns after the input stream is complete.
    #[structopt(short, long)]
    sync: bool,
}

impl Filter {
    /// Firstly try building the Source from shell command, then the input file, finally reading the source from stdin.
    fn generate_source<I: Iterator<Item = SourceItem>>(&self) -> Source<I> {
        if let Some(ref cmd_str) = self.cmd {
            if let Some(ref dir) = self.cmd_dir {
                subprocess::Exec::shell(cmd_str).cwd(dir).into()
            } else {
                subprocess::Exec::shell(cmd_str).into()
            }
        } else {
            self.input
                .clone()
                .map(Into::into)
                .unwrap_or(Source::<I>::Stdin)
        }
    }

    fn get_bonuses(&self) -> Vec<Bonus> {
        use std::io::BufRead;

        let mut bonuses = vec![self.bonus.clone().unwrap_or_default()];
        if let Some(ref recent_files) = self.recent_files {
            // Ignore the error cases.
            if let Ok(file) = std::fs::File::open(recent_files) {
                let lines: Vec<String> = std::io::BufReader::new(file)
                    .lines()
                    .filter_map(|x| x.ok())
                    .collect();
                bonuses.push(Bonus::RecentFiles(lines.into()));
            }
        }

        bonuses
    }

    /// Returns the results until the input stream is complete.
    #[inline]
    fn sync_run(
        &self,
        Params {
            number,
            winwidth,
            icon_painter,
            ..
        }: Params,
    ) -> Result<()> {
        let ranked = filter::sync_run::<std::iter::Empty<_>>(
            &self.query,
            self.generate_source(),
            self.algo.clone().unwrap_or(Algo::Fzy),
            self.match_type.clone().unwrap_or(MatchType::Full),
            self.get_bonuses(),
        )?;

        printer::print_sync_filter_results(ranked, number, winwidth.unwrap_or(100), icon_painter);

        Ok(())
    }

    #[inline]
    fn dyn_run(
        &self,
        Params {
            number,
            winwidth,
            icon_painter,
            ..
        }: Params,
    ) -> Result<()> {
        filter::dyn_run::<std::iter::Empty<_>>(
            &self.query,
            self.generate_source(),
            FilterContext::new(
                self.algo.clone(),
                number,
                winwidth,
                icon_painter,
                self.match_type.clone().unwrap_or(MatchType::Full),
            ),
            self.get_bonuses(),
        )
    }

    pub fn run(&self, params: Params) -> Result<()> {
        if self.sync {
            self.sync_run(params)?;
        } else {
            self.dyn_run(params)?;
        }
        Ok(())
    }
}
