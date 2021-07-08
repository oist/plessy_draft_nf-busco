#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BUSCO } from './modules/nf-core/software/busco/main.nf'  addParams( options: [args: '--offline'] )

workflow {
    channel
        .value( params.lineage )
        .map { filename -> file(filename, checkIfExists: true) }
        .set { lineage }

    channel
        .fromPath( params.input )
        .splitCsv( header:true, sep:"\t" )
        .map { row -> [ row,
    		    file(row.genome, checkIfExists: true),
    		    file(row.augustus_config, checkIfExists: true),
    		    row.species ] }
        .set { input }

    BUSCO (input, lineage)
}
