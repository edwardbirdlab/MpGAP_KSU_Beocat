/*
 * DEFINITION OF MULTI-SAMPLE (BATCH) MODE
 */

/*
 * Include modules
 */
include { spades    } from '../modules/ShortReads/spades_sreads.nf'
include { unicycler } from '../modules/ShortReads/unicycler_sreads.nf'
include { shovill   } from '../modules/ShortReads/shovill_sreads.nf'
include { megahit   } from '../modules/ShortReads/megahit_sreads.nf'

workflow SHORTREADS_ONLY {

  take:
      input_tuple
  
  main:

  // Define default output channes
  // default must be a empty channel that
  // will be overwritten if assembler is used
  def SHORTREADS_OUTPUTS = [:]
  SHORTREADS_OUTPUTS['SPADES']    = Channel.empty()
  SHORTREADS_OUTPUTS['UNICYCLER'] = Channel.empty()
  SHORTREADS_OUTPUTS['SHOVILL']   = Channel.empty()
  SHORTREADS_OUTPUTS['MEGAHIT']   = Channel.empty()

  // SPAdes
  if (!params.skip_spades) {
    spades(input_tuple)
    SHORTREADS_OUTPUTS['SPADES'] = spades.out[1]
  }
  // Unicycler
  if (!params.skip_unicycler) {
    unicycler(input_tuple)
    SHORTREADS_OUTPUTS['UNICYCLER'] = unicycler.out[1]
  }
  // Shovill
  if (!params.skip_shovill) {
    shovill(input_tuple.combine(Channel.from('spades', 'skesa', 'megahit')))
    SHORTREADS_OUTPUTS['SHOVILL'] = shovill.out[1]
  }
  // Megahit
  if (!params.skip_megahit) {
    megahit(input_tuple)
    SHORTREADS_OUTPUTS['MEGAHIT'] = megahit.out[1]
  }

  // Gather assemblies for qc
  SHORTREADS_OUTPUTS['ALL_RESULTS'] = SHORTREADS_OUTPUTS['SPADES']
                                      .mix(
                                        SHORTREADS_OUTPUTS['UNICYCLER'], 
                                        SHORTREADS_OUTPUTS['SHOVILL'],
                                        SHORTREADS_OUTPUTS['MEGAHIT']
                                      )
                                      .combine(input_tuple, by: 0)

  emit:
  SHORTREADS_OUTPUTS['ALL_RESULTS']

}