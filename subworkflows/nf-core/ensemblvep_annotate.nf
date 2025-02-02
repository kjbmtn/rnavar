//
// Run VEP to annotate VCF files
//

//params.bgziptabix_vep = [:]
//params.vep_options    = [:]
//params.vep_tag        = [:]
//params.use_cache      = [:]

include { ENSEMBLVEP } from '../../modules/nf-core/modules/ensemblvep/main'
//addParams(
//    options:   params.vep_options,
//    use_cache: params.use_cache,
//    vep_tag:   params.vep_tag
//)

include { TABIX_BGZIPTABIX } from '../../modules/nf-core/modules/tabix/bgziptabix/main' //addParams(options: params.bgziptabix_vep_options)

workflow ENSEMBLVEP_ANNOTATE {
    take:
    vcf               // channel: [ val(meta), vcf, tbi ]
    vep_genome        //   value: which genome
    vep_species       //   value: which species
    vep_cache_version //   value: which cache version
    vep_cache         //    path: path_to_vep_cache (optionnal)
    // skip           // boolean: true/false

    main:

    ch_versions = Channel.empty()

    ENSEMBLVEP(vcf, vep_genome, vep_species, vep_cache_version, vep_cache)
    ch_versions = ch_versions.mix(ENSEMBLVEP.out.versions.first())
    TABIX_BGZIPTABIX(ENSEMBLVEP.out.vcf)
    ch_versions = ch_versions.mix(TABIX_BGZIPTABIX.out.versions.first())

    emit:
    vcf_tbi     = TABIX_BGZIPTABIX.out.gz_tbi    // channel: [ val(meta), vcf, tbi ]
    reports     = ENSEMBLVEP.out.report          // path: *.html
    versions    = ch_versions                    // channel: [versions.yml]
}
