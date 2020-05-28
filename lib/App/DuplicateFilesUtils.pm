package App::DuplicateFilesUtils;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::ger;

our %SPEC;

$SPEC{':package'} = {
    v => 1.1,
    summary => 'CLI utilities related to duplicate files',
};

$SPEC{show_duplicate_files} = {
    v => 1.1,
    summary => 'Show duplicate files',
    description => <<'_',

This is actually a shortcut for:

    % uniq-files -a --count --show-size --group-by-digest -R .

_
    args => {
    },
    features => {
    },
    examples => [
    ],
};
sub show_duplicate_files {
    require App::UniqFiles;
    App::UniqFiles::uniq_files(
        report_unique=>1, report_duplicate=>1, # -a
        count=>1, show_size=>1,
        group_by_digest=>1,
        recurse=>1, files=>['.'],
    );
}

$SPEC{move_duplicate_files_to} = {
    v => 1.1,
    summary => 'Move duplicate files (except one copy) to a directory',
    description => <<'_',

Moving is currently done using Perl's `rename()`, so files cannot be moved
across filesystems.

See also: <prog:show-duplicate-files> which lets you manually select which
copies of the duplicate sets you want to move/delete.

_
    args => {
        dir => {
            summary => 'Directory to move duplicate files into',
            schema => 'dirname*',
            pos => 0,
            req => 1,
        },
    },
    features => {
        dry_run => {default=>1},
    },
    examples => [
        {
            summary => 'See which duplicate files will be moved (a.k.a. dry-run mode by default)',
            argv => ['.dupe/'],
            test => 0,
            'x.doc.show_result' => 0,
        },
        {
            summary => 'Actually move duplicate files to .dupe/ directory',
            argv => ['--no-dry-run', '.dupe/'],
            test => 0,
            'x.doc.show_result' => 0,
        },
    ],
};
sub move_duplicate_files_to {
    my %args = @_;

    my $dir = $args{dir} or return [400, "Please specify dir"];
    (-d $dir) or return [412, "Target directory '$dir' does not exist"];

    require App::UniqFiles;
    my $res = App::UniqFiles::uniq_files(
        report_unique => 0,
        report_duplicate => 3,
        recurse => 1, files => ['.'],
        count => 1,
    );
    return [500, "Can't uniq_files: $res->[0] - $res->[1]"] unless $res->[0] == 200;

    for my $f (@{ $res->[2] }) {
        if ($args{-dry_run}) {
            log_info "[DRY-RUN] Moving duplicate file %s to %s ...", $f, $dir;
        } else {
            log_info "Moving duplicate file %s to %s ...", $f, $dir;
            rename $f, "$dir/$f" or do {
                log_error "Failed moving %s to %s: %s", $f, $dir, $!;
            };
        }
    }

    [200];
}

1;
#ABSTRACT:

=head1 DESCRIPTION

This distributions provides the following command-line utilities:

# INSERT_EXECS_LIST


=head1 SEE ALSO

L<uniq-files> from L<App::UniqFiles>

L<find-duplicate-filenames> from L<App::FindUtils>

=cut
