### Phase 0: Extract and Analyze Historical Workspace Archives

**IMPORTANT: Complete this phase FIRST before proceeding to BMW analysis.**

#### Context

The `incoming/` directory contains **20 historical workspace archive files** (files 20-39) from previous Claude AI sessions. These archives may contain:
- Uncommitted work lost during authentication issues
- Test results and analysis reports
- Implementation code and patches
- Documentation and notes

#### Your Task

1. **Extract all archives**
   ```bash
   # Create extraction workspace
   mkdir -p /home/claude/work/archive-review
   cd /home/claude/workspace-transfer/incoming
   
   # Extract all zip files
   for zipfile in files*.zip; do
       echo "Extracting $zipfile..."
       unzip -q "$zipfile" -d /home/claude/work/archive-review/
   done
   ```

2. **Create inventory**
   
   Create `/home/claude/work/inventory-archives.pl`:
   
   ```perl
   #!/usr/bin/perl
   use v5.24;
   use strict;
   use warnings;
   use File::Find;
   use File::Basename;
   use Digest::SHA qw(sha256_hex);
   
   my $archive_dir = '/home/claude/work/archive-review';
   my $repo_dir = '/home/claude/workspace-transfer';
   my $output_file = '/mnt/user-data/outputs/archive-inventory-report.md';
   
   my %archive_files;
   my %repo_files;
   
   # Helper function for safe SHA256 calculation
   sub safe_sha256 {
       my $file = shift;
       
       open my $fh, '<:raw', $file or do {
           warn "⚠️  Cannot read $file: $!\n";
           return 'ERROR_UNREADABLE';
       };
       
       local $/;
       my $content = <$fh>;
       close $fh;
       
       return sha256_hex($content);
   }
   
   # Scan archive directory
   find(sub {
       return unless -f $_;
       my $rel_path = $File::Find::name;
       $rel_path =~ s/^\Q$archive_dir\E\/?//;
       $archive_files{$rel_path} = {
           path => $File::Find::name,
           size => -s $_,
           sha256 => safe_sha256($_)
       };
   }, $archive_dir);
   
   # Scan repository directory (exclude .git and incoming)
   find(sub {
       return if $File::Find::dir =~ m{/\.git(/|$)};
       return if $File::Find::dir =~ m{/incoming(/|$)};
       return unless -f $_;
       my $rel_path = $File::Find::name;
       $rel_path =~ s/^\Q$repo_dir\E\/?//;
       $repo_files{$rel_path} = {
           path => $File::Find::name,
           size => -s $_,
           sha256 => safe_sha256($_)
       };
   }, $repo_dir);

   # Generate report
   open my $out, '>', $output_file or die "Cannot write to $output_file: $!";
   
   print $out "# Archive Inventory Report\n\n";
   print $out "**Generated**: " . scalar(localtime) . "\n\n";
   print $out "---\n\n";
   
   print $out "## Summary\n\n";
   print $out sprintf("- Archive files found: %d\n", scalar keys %archive_files);
   print $out sprintf("- Repository files: %d\n", scalar keys %repo_files);
   print $out "\n---\n\n";
   
   # Find files only in archive
   my @only_in_archive;
   my @modified_files;
   my @identical_files;
   
   for my $file (sort keys %archive_files) {
       if (!exists $repo_files{$file}) {
           push @only_in_archive, $file;
       } elsif ($archive_files{$file}{sha256} ne $repo_files{$file}{sha256}) {
           push @modified_files, $file;
       } else {
           push @identical_files, $file;
       }
   }
   
   # Report files only in archive (potential uncommitted work)
   if (@only_in_archive) {
       print $out "## ⚠️  Files Only in Archives (Potentially Uncommitted)\n\n";
       print $out sprintf("**Count**: %d files\n\n", scalar @only_in_archive);
       
       for my $file (@only_in_archive) {
           my $info = $archive_files{$file};
           print $out sprintf("- `%s` (%d bytes)\n", $file, $info->{size});
       }
       print $out "\n---\n\n";
   }
   
   # Report modified files
   if (@modified_files) {
       print $out "## 🔄 Files Modified Between Archive and Repository\n\n";
       print $out sprintf("**Count**: %d files\n\n", scalar @modified_files);
       
       for my $file (@modified_files) {
           my $arch = $archive_files{$file};
           my $repo = $repo_files{$file};
           print $out sprintf("- `%s`\n", $file);
           print $out sprintf("  - Archive: %d bytes (SHA256: %s...)\n", 
                            $arch->{size}, substr($arch->{sha256}, 0, 16));
           print $out sprintf("  - Repo: %d bytes (SHA256: %s...)\n", 
                            $repo->{size}, substr($repo->{sha256}, 0, 16));
       }
       print $out "\n---\n\n";
   }
   
   # Report identical files
   print $out "## ✅ Files Identical in Both\n\n";
   print $out sprintf("**Count**: %d files\n\n", scalar @identical_files);
   print $out "\n---\n\n";
   
   print $out "## Recommendations\n\n";
   if (@only_in_archive) {
       print $out "1. Review files only in archives for potential recovery\n";
       print $out "2. Commit valuable content to repository\n";
       print $out "3. Update documentation if needed\n";
   } else {
       print $out "✅ All archive content appears to be in repository already.\n";
   }
   
   close $out;
   
   say "✅ Inventory report generated: $output_file";
   say sprintf("   - Files only in archive: %d", scalar @only_in_archive);
   say sprintf("   - Modified files: %d", scalar @modified_files);
   say sprintf("   - Identical files: %d", scalar @identical_files);
   ```

3. **Run inventory**
   ```bash
   cd /home/claude/work
   chmod +x inventory-archives.pl
   perl inventory-archives.pl
   ```

4. **Review findings**
   ```bash
   cat /mnt/user-data/outputs/archive-inventory-report.md
   ```

5. **Extract important content**
   - If uncommitted files found, review them
   - Commit valuable content to workspace-transfer repository
   - Document findings in the inventory report

#### Success Criteria

- ✅ All 20 archives extracted
- ✅ Inventory report generated
- ✅ Uncommitted content identified (if any)
- ✅ Important files recovered and committed

**Once Phase 0 is complete, proceed to Phase 1 (BMW Analysis).**

---
