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

    % uniq-files -a --show-count --show-size --group-by-digest -R .

Sample output:

    % show-duplicate-files
    +------------------------------+---------+-------+
    | file                         | size    | count |
    +------------------------------+---------+-------+
    | ./tmp/P_20161001_112707.jpg  | 1430261 | 2     |
    | ./tmp2/P_20161001_112707.jpg | 1430261 | 2     |
    |                              |         |       |
    | ./20160420/IMG_3430-(95).JPG | 1633463 | 2     |
    | ./tmp/IMG_3430-(95).JPG      | 1633463 | 2     |
    |                              |         |       |
    | ./tmp/P_20161009_081735.jpg  | 1722586 | 2     |
    | ./tmp2/P_20161009_081735.jpg | 1722586 | 2     |
    |                              |         |       |
    | ./20160420/IMG_3430-(98).JPG | 1847543 | 3     |
    | ./tmp/IMG_3430-(98).JPG      | 1847543 | 3     |
    | ./tmp2/IMG_3430-(98).JPG     | 1847543 | 3     |
    |                              |         |       |
    | ./20160420/IMG_3430-(97).JPG | 1878472 | 2     |
    | ./tmp/IMG_3430-(97).JPG      | 1878472 | 2     |
    |                              |         |       |
    | ./20160420/IMG_3430-(99).JPG | 1960652 | 3     |
    | ./tmp/IMG_3430-(99).JPG      | 1960652 | 3     |
    | ./tmp2/IMG_3430-(99).JPG     | 1960652 | 3     |
    |                              |         |       |
    | ./20160420/IMG_3430-(96).JPG | 2042952 | 2     |
    | ./tmp/IMG_3430-(96).JPG      | 2042952 | 2     |
    |                              |         |       |
    | ./20160420/IMG_3430-(92).JPG | 2049127 | 2     |
    | ./tmp/IMG_3430-(92).JPG      | 2049127 | 2     |
    |                              |         |       |
    | ./20160420/IMG_3430-(94).JPG | 2109852 | 2     |
    | ./tmp/IMG_3430-(94).JPG      | 2109852 | 2     |
    |                              |         |       |
    | ./20160420/IMG_3430-(91).JPG | 2138724 | 2     |
    | ./tmp/IMG_3430-(91).JPG      | 2138724 | 2     |
    |                              |         |       |
    | ./20160420/IMG_3430-(93).JPG | 2190379 | 2     |
    | ./tmp/IMG_3430-(93).JPG      | 2190379 | 2     |
    +------------------------------+---------+-------+

You can then delete or move the duplicates manually, if you want. But there's
also <prog:move-duplicate-files-to> to automatically move all the duplicates
(but one, for each set) to a directory of your choice.

To perform other actions on the duplicate copies, for example delete them, you
can use <prog:uniq-files> directly e.g. (in bash):

    % uniq-files -R -D * | while read f; do rm "$p"; done

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
        report_unique=>0, report_duplicate=>1, # -a
        count=>1, show_size=>1,
        group_by_digest=>1,
        recurse=>1, files=>['.'],
    );
}

$SPEC{move_duplicate_files_to} = {
    v => 1.1,
    summary => 'Move duplicate files (except one copy) to a directory',
    description => <<'_',

This utility will find all duplicate sets of files and move all of the
duplicates (except one) for each set to a directory of your choosing.

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
            src => 'move-duplicate-files-to .dupe/',
            src_plang => 'bash',
            test => 0,
            'x.doc.show_result' => 0,
        },
        {
            summary => 'Actually move duplicate files to .dupe/ directory',
            src => 'move-duplicate-files-to .dupe/ --no-dry-run',
            src_plang => 'bash',
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
        show_count => 1,
    );
    return [500, "Can't uniq_files: $res->[0] - $res->[1]"] unless $res->[0] == 200;

    for my $rec (@{ $res->[2] }) {
        my $src = $rec->{file};
        (my $srcbase = $src) =~ s!.+/!!;
        my $dest = "$dir/$srcbase";
        if ($args{-dry_run}) {
            log_info "[DRY-RUN] Moving duplicate file %s to %s ...", $src, $dest;
        } else {
            require File::Copy;
            log_info "Moving duplicate file %s to %s ...", $src, $dest;
            File::Copy::move($src, $dest) or do {
                log_error "Failed moving %s to %s: %s", $src, $dest, $!;
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
