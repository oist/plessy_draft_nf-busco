# BUSCO with custom AUGUSTUS models

## Mandatory parameters

 * `--lineage`: path to one lineage dataset (uncompresses in a directory)

 * `--input`: path to a sample sheet in tab-separated format with one header
   line `id`, `genome`, `augustus_config`, `species`, and one row per
   combination of genome and AUGUSTUS species combination (ID and path to
   files, species name).

## Test

### test remote

    TBD

### test locally

    nextflow run ./main.nf -profile oist --input input.tsv --lineage /bucket/LuscombeU/common/OrthoDB/metazoa_odb10

## Advanced use

### Override computation limits

Computation resources allocated to the processe are set with standard _nf-core_
labels in the [`nextflow.config`](./nextflow.config) file of the pipeline.  To
override their value, create a configuration file in your local directory and
add it to the run's configuration with the `-c` option.

For instance, with file called `overrideLabels.nf` containing the following:

```
process {
  withLabel:process_high {
    time = 3.d
  }
}
```

The command `nextflow -c overrideLabels.nf run …` would set the execution time
limit for the training and alignment (whose module declare the `process_high`
label) to 3 days instead of the 1 hour default.


## Semantic versioning

I will apply [semantic versioning](https://semver.org/) to this pipeline:

 - Major increment when the interface changes in a way that is
   backwards-incompatible, in the sense that a run with the same command and
   the same data would produce a different result (except for non-deterministic
   computations).

 - Minor increment for any other change of the interface, such as additions of
   new functionalities.

 - Patch increment for changes that do not modify the interface (bug fixes,
   minor software and module updates, documentation changes, etc.)
