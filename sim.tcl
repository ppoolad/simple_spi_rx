vlib work
vlog -L mtiAvm -L mtiRnm -L mtiOvm -L mtiUvm -L mtiUPF -L infact ./axi_rx.v
vlog -L mtiAvm -L mtiRnm -L mtiOvm -L mtiUvm -L mtiUPF -L infact ./axi_rx_tb.v

vsim -voptargs=+acc work.test_axi_rx
add wave -position insertpoint sim:/test_axi_rx/*

add wave -divider -height 30 "UUT"

add wave -position insertpoint sim:/test_axi_rx/uut/*

run 1000ns
