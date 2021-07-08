include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process BUSCO {
    tag "$meta.id"
    label 'process_high'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "bioconda::busco=5.2.1" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/busco:5.2.1--pyhdfd78af_0"
    } else {
        container "quay.io/biocontainers/busco:5.2.1--pyhdfd78af_0"
    }

    input:
    tuple val(meta), path(fasta), path(augustus_config), val(species)
    val(lineage)

    output:
    tuple val(meta), path("${meta.id}/run_*/full_table.tsv"),    emit: tsv
    tuple val(meta), path("${meta.id}/run_*/short_summary.txt"), emit: txt
    path "*.version.txt",                                        emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    if (lineage) options.args += " --lineage_dataset $lineage"
    """
    if [ -e $augustus_config ]
    then
        # Copy the AUGUSTUS config directory as BUSO needs write access
        cp -rL $augustus_config ${augustus_config}_copy && export AUGUSTUS_CONFIG_PATH=${augustus_config}_copy
    else
        # Copy the image's AUGUSTUS config directory if it was not provided to the module
        cp -a /usr/local/config augustus_config && export AUGUSTUS_CONFIG_PATH='augustus_config'
    fi
    busco \\
        $options.args \\
        --augustus \\
        --augustus_species $species \\
        --mode genome \\
        --cpu $task.cpus \\
        --in  $fasta \\
        --out $meta.id

    echo \$(busco --version 2>&1) | sed 's/^BUSCO //' > ${software}.version.txt
    """
}
