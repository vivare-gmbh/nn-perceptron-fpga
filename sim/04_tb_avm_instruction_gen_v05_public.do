# generate foreign module declaration
onerror {resume}

# create library
if [file exists  {./work}] {
    vdel -all  {./work}
}
vlib  {./work}
 
#
# Add logical mapping >work< to the local design simulation library
#
vmap work {./work}

#pwd


#
# Open debugging windows
#
quietly view *

#
# Start and run simulation
#
set StdArithNoWarnings 1
vcom  -work "work" -nologo -2008 -F 03_file_list.txt
vcom  -work "work" -nologo -93 ../tb/vhdl/tb_avm_instruction_gen_v05_public.vhd

vsim -no_autoacc -L work -coverage -voptargs="+cover=bcesfx" -l transcript.txt -i -multisource_delay latest -t ns +typdelays work.tb_avm_instruction_gen_v05_public(testbench)

assertion active
assertion profile on
assertion report -verbose


configure wave -namecolwidth 450
#configure wave -valuecolwidth 145
configure wave -valuecolwidth 120
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update


# View the results.
#if {![batch_mode]} {
    
    quietly add  wave -divider TB_TOP_LEVEL 
    quietly add  wave -expand  /stream01
    quietly add  wave -expand  /stream02
    quietly add  wave -group TB_TOP_LEVEL /*

    quietly add  wave -divider TOP_LEVEL 
    quietly add  wave -group TOP_LEVEL /u_0/*

    quietly add  wave -divider PERCEPTRON 
    quietly add  wave -group PERCEPTRON /u_0/u_0/*

    quietly add  wave -divider WISHBONE
    quietly add  wave -group WISHBONE /u_0/u_0/u_14/*

    quietly add  wave -divider FOR_LOOP_I 
    quietly add  wave -group FOR_LOOP_I /u_0/u_0/u_2/*

    quietly add  wave -divider FOR_LOOP_J 
    quietly add  wave -group FOR_LOOP_J /u_0/u_0/u_1/*

    quietly add  wave -divider CAL_Y 
    quietly add  wave -group CAL_Y /u_0/u_0/u_0/*

    quietly add  wave -divider CAL_W
    quietly add  wave -group CAL_W /u_0/u_0/u_8/*

    quietly add  wave -divider INIT
    quietly add  wave -group INIT /u_0/u_0/u_9/*

    quietly add  wave -divider TEST
    quietly add  wave -group TEST /u_0/u_0/u_10/*

    quietly add  wave -divider READ_WRITE
    quietly add  wave -group READ_WRITE /u_0/u_0/u_11/*

    quietly add  wave -divider TRAINING
    quietly add  wave -group TRAINING /u_0/u_0/u_12/*

    quietly add  wave -divider LATENCY
    quietly add  wave -group LATENCY /u_0/u_0/u_13/*

    quietly add  wave -divider S-MEMORY
    quietly add  wave -group S-MEMORY /u_0/u_1/u_0/*

    quietly add  wave -divider T-MEMORY
    quietly add  wave -group T-MEMORY /u_0/u_1/u_1/*

    quietly add  wave -divider Y-MEMORY
    quietly add  wave -group Y-MEMORY /u_0/u_1/u_2/*

    quietly add  wave -divider BIAS-MEMORY
    quietly add  wave -group BIAS-MEMORY /u_0/u_1/u_3/*

    quietly add  wave -divider W-MEMORY
    quietly add  wave -group W-MEMORY /u_0/u_1/u_4/*

    #quietly add  wave -r /*
    
#}

run -all
quietly wave zoomfull 
update

#U_0/U_0/U_0
coverage exclude -du p0300_m00022_s_v02_cal_y_fsm -ftrans current_state S01->S00 \
                                                                        S02->S00 \
                                                                        S03->S00 \
                                                                        S04->S00 \
                                                                        S05->S00 \
                                                                        S06->S00 \
                                                                        S07->S00 \
                                                                        S08->S00 \
                                                                        S09->S00 \
                                                                        S10->S00 \
                                                                        S11->S00 \
                                                                        S12->S00 \
                                                                        S13->S00 \
                                                                        S14->S00 \
                                                                        S15->S00 \
                                                                        S16->S00

#U_0/U_0/U_1
coverage exclude -du p0300_m00034_s_v01_for_loop_memwj_fsm -ftrans current_state S01->S00 \
                                                                                 S02->S00 \
                                                                                 S03->S00 \
                                                                                 S04->S00 \
                                                                                 S05->S00 \
                                                                                 S06->S00

#U_0/U_0/U_2
coverage exclude -du p0300_m00033_s_v01_for_loop_memwi_fsm -ftrans current_state S01->S00 \
                                                                                 S02->S00 \
                                                                                 S03->S00 \
                                                                                 S04->S00 \
                                                                                 S05->S00 \
                                                                                 S06->S00

#U_0/U_0/U_8
coverage exclude -du p0300_m00023_s_v02_cal_w_fsm -ftrans current_state S01->S00 \
                                                                        S02->S00 \
                                                                        S03->S00 \
                                                                        S04->S00 \
                                                                        S05->S00 \
                                                                        S06->S00 \
                                                                        S07->S00 \
                                                                        S08->S00 \
                                                                        S09->S00 \
                                                                        S10->S00 \
                                                                        S11->S00 \
                                                                        S12->S00 \
                                                                        S13->S00 \
                                                                        S14->S00 \
                                                                        S15->S00 \
                                                                        S16->S00

#U_0/U_0/U_9
coverage exclude -du p0300_m00025_s_v02_init_fsm -ftrans current_state S01->S00 \
                                                                       S02->S00 \
                                                                       S03->S00 \
                                                                       S04->S00 \
                                                                       S05->S00 \
                                                                       S06->S00 \
                                                                       S07->S00 \
                                                                       S08->S00

#U_0/U_0/U_10
coverage exclude -du p0300_m00024_s_v02_test_fsm -ftrans current_state S01->S00 \
                                                                       S02->S00 \
                                                                       S03->S00 \
                                                                       S04->S00 \
                                                                       S05->S00 \
                                                                       S06->S00 \
                                                                       S07->S00 \
                                                                       S08->S00 \
                                                                       S09->S00 \
                                                                       S10->S00 \
                                                                       S11->S00 \
                                                                       S12->S00 \
                                                                       S13->S00 \
                                                                       S14->S00 \
                                                                       S15->S00 \
                                                                       S16->S00 \
                                                                       S17->S00

#U_0/U_0/U_11
coverage exclude -du p0300_m00026_s_v02_rd_wr_fsm -ftrans current_state S01->S00 \
                                                                        S02->S00 \
                                                                        S12->S00 \
                                                                        S22->S00 \
                                                                        S32->S00 \
                                                                        S42->S00 \
                                                                        S03->S00 \
                                                                        S04->S00

#U_0/U_0/U_12
coverage exclude -du p0300_m00027_s_v01_train_fsm -ftrans current_state S01->S00 \
                                                                        S02->S00 \
                                                                        S03->S00 \
                                                                        S04->S00 \
                                                                        S05->S00 \
                                                                        S06->S00 \
                                                                        S07->S00 \
                                                                        S08->S00 \
                                                                        S09->S00 \
                                                                        S10->S00 \
                                                                        S11->S00 \
                                                                        S12->S00 \
                                                                        S13->S00

#U_0/U_0/U_13
coverage exclude -du p0300_m00028_s_v02_latency_fsm -ftrans current_state S01->S00 \
                                                                          S02->S00 \
                                                                          S03->S00 \
                                                                          S04->S00 \
                                                                          S05->S00 \
                                                                          S06->S00 \
                                                                          S07->S00 \
                                                                          S08->S00 \
                                                                          S09->S00 \
                                                                          S10->S00 \
                                                                          S11->S00 \
                                                                          SRDY->S00 \
                                                                          SERR->S00

#U_0/U_0/U_14
coverage exclude -du p0300_m00021_s_v03_wishbone_fsm -ftrans current_state S01->S00 \
                                                                           S01a->S00 \
                                                                           S02->S00 \
                                                                           S03->S00 \
                                                                           S04->S00 \
                                                                           S05->S00 \
                                                                           S06->S00 \
                                                                           S07->S00 \
                                                                           S08->S00 \
                                                                           S09->S00 \
                                                                           S10->S00 \
                                                                           S11->S00 \
                                                                           S12->S00 \
                                                                           S13->S00 \
                                                                           S14->S00 \
                                                                           S15->S00 \
                                                                           S16->S00 \
                                                                           S17->S00 \
                                                                           S18->S00 \
                                                                           S19->S00 \
                                                                           S20->S00 \
                                                                           S21->S00 \
                                                                           S22->S00 \
                                                                           S23->S00 \
                                                                           S24->S00 \
                                                                           S25->S00 \
                                                                           S26->S00 \
                                                                           S27->S00 \
                                                                           S28->S00 \
                                                                           S29->S00 \
                                                                           S30->S00 \
                                                                           S31->S00 \
                                                                           S32->S00 \
                                                                           S33->S00 \
                                                                           S34->S00 \
                                                                           S35->S00 \
                                                                           S36->S00 \
                                                                           S37->S00 \
                                                                           S38->S00 \
                                                                           S39->S00 \
                                                                           S40->S00 \
                                                                           S41->S00 \
                                                                           S42->S00 \
                                                                           S43->S00 \
                                                                           S44->S00 \
                                                                           S45->S00 \
                                                                           S46->S00 \
                                                                           S47->S00 \
                                                                           S48->S00

