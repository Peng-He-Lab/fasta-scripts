# fasta-scripts

A set of command-line Python (and shell) scripts for common FASTA processing tasks (trimming, filtering, format cleanup, sequence extraction, QC, and utilities).

Most scripts were originally written by Georgi Marinov; a few were added or updated by Peng He. They live in `scripts/` and are designed to be run from the shell (some accept `-` for stdin/stdout so they can be piped).

```bash
python scripts/trimfasta.py reads.fa 50 > trimmed.fa
bash scripts/GetFastaLengths.sh genome.fa
```

## Trimming / filtering

### `trimfasta.py`

Trims each sequence to a fixed number of bases from the 5′ end.

Supports stdin (`-`), prints to stdout by default, optional `N`→base replacement, and bulk ID renaming with a prefix.

```bash
python scripts/trimfasta.py input.fa 36
python scripts/trimfasta.py - 50 -Nto A -renameIDs read < input.fa > trimmed.fa
```

### `trimpolyA.py`

Finds reads with a 3′ poly(A) (or 5′ poly(T), reverse-complemented) tail and trims the A-tail, keeping only reads that meet a minimum residual length.

Optional mismatch tolerance in the A-tail and a `-first` limit for testing.

```bash
python scripts/trimpolyA.py input.fa 10 20 trimmed.fa
python scripts/trimpolyA.py input.fa 10 20 trimmed.fa -Amismatches 1 -first 1000
```

### `fastaMinLength.py`

Keeps sequences at or above a minimum length and rewrites them with a fixed line-wrap block size.

```bash
python scripts/fastaMinLength.py input.fa 200 60 filtered.fa
```

### `filterlongfasta.py`

Keeps sequences longer than a length cutoff (opposite of a short-sequence filter).

```bash
python scripts/filterlongfasta.py transcripts.fa long.fa 300
```

### `fastaSubset.py`

Extracts a subset of FASTA records whose IDs appear in a wanted list.

The wanted file is tab-delimited; `fieldID` selects which column holds the sequence ID to match against FASTA headers.

```bash
python scripts/fastaSubset.py wanted.txt 0 input.fa subset.fa
```

## Format conversion & cleanup

### `fixFasta.py`

Cleans FASTA header lines so tools like Bowtie do not truncate IDs at whitespace.

By default replaces spaces with underscores; with an extra `split` argument, keeps only the first whitespace-delimited field of the header.

```bash
python scripts/fixFasta.py input.fa fixed.fa
python scripts/fixFasta.py input.fa fixed.fa split
```

### `fastaBlocks.py`

Rewraps FASTA sequences to a fixed line length (`blockSize`).

Optional `-replaceXwithN` and `-replaceNames` (tab file of `old_name <tab> new_name`; sequences without a new name are skipped).

```bash
python scripts/fastaBlocks.py input.fa 60 wrapped.fa
python scripts/fastaBlocks.py input.fa 60 wrapped.fa -replaceXwithN -replaceNames names.tsv
```

### `collapseFasta.py`

Collapses identical sequences and writes unique reads as FASTA (`>readN`).

```bash
python scripts/collapseFasta.py input.fa unique.fa
```

### `tab-to-fasta.sh`

Converts a two-column tab-delimited file (`name <tab> sequence`) into a FASTA file named after the input (`.fasta` extension).

```bash
bash scripts/tab-to-fasta.sh sequences.tsv
```

### `contig_fasta2gtf.py`

Converts a contig FASTA into a simple GTF with one exon feature per contig spanning the full sequence length.

```bash
python scripts/contig_fasta2gtf.py contigs.fa contigs.gtf
```

### `multipleGenomesFasta.py`

Merges many FASTA files into one, prefixing each header with a genome label (`label:original_id`).

Input list format: `filename <tab> label` (e.g. `mm9.fa <tab> mm9`).

```bash
python scripts/multipleGenomesFasta.py filelist.txt pooled.fa
```

## Extraction / subsetting

### `getFastaFromFasta.py`

Extracts subsequences from a reference FASTA using genomic intervals (BED-like / peak tables).

Supports peak-centered extraction (`-usepeak`, `-narrowPeak`, `-seqradius`), custom chromosome/name/strand fields, and reverse-complement on the minus strand.

```bash
python scripts/getFastaFromFasta.py genome.fa peaks.bed peaks.fa -usepeak bed
python scripts/getFastaFromFasta.py genome.fa regions.tsv out.fa -seqradius 100 -strand 5
```

### `genome-to-kmer-fasta.py`

Builds all *k*-mers from a FASTA genome, then samples a requested number of reads (with reverse-complemented odd-numbered entries) into an output FASTA.

```bash
python scripts/genome-to-kmer-fasta.py genome.fa kmers.fa 30 100000
```

### `partitionGenome.py`

Tiles a `chrom.sizes` file into fixed-width genomic windows (BED-like `chr start end` lines).

```bash
python scripts/partitionGenome.py chrom.sizes 1000 windows.bed
```

## QC / composition statistics

### `fastaGC.py`

Reports per-sequence length and GC% for every record in a FASTA file.

```bash
python scripts/fastaGC.py genome.fa gc.tsv
```

### `basePairComposition.py`

Computes overall A/C/T/G fractional composition across an entire FASTA file.

```bash
python scripts/basePairComposition.py input.fa composition.tsv
```

### `calculateGenomeGCcontent.py`

Computes GC% for each file in a genome directory (one chromosome/contig FASTA per file).

```bash
python scripts/calculateGenomeGCcontent.py chroms/ gc_summary.txt
```

### `fastReadLengthDist.py`

Computes a full length histogram for FASTA (`-f`) or FASTQ (`-q`) input.

Accepts `-` for stdin.

```bash
python scripts/fastReadLengthDist.py input.fa lengths.tsv -f
python scripts/fastReadLengthDist.py input.fastq lengths.tsv -q
```

### `GetFastaLengths.sh`

Prints the length of each sequence in a FASTA file (`id,length` per line). Originally by Daniel E. Cook.

```bash
bash scripts/GetFastaLengths.sh genome.fa
```

## Utilities

### `shufflefasta.py`

Randomly shuffles the bases within each sequence (headers unchanged). Useful for generating composition-matched null sequences.

```bash
python scripts/shufflefasta.py input.fa shuffled.fa
```

### `splitfastaintosmallerfiles.py`

Splits a multi-sequence FASTA into smaller files whose total sequence length stays under a maximum piece size.

```bash
python scripts/splitfastaintosmallerfiles.py large.fa 100000000 pieces
```
