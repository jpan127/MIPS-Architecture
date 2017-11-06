# Clock
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5}   [get_ports { clock_100MHz   }];
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 }        [get_ports { clock_100MHz   }];

# Buttons
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 }        [get_ports { button         }];
set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 }        [get_ports { reset          }];
   
# Controls
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 }        [get_ports { rf_ra[0]       }];
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 }        [get_ports { rf_ra[1]       }];
set_property -dict { PACKAGE_PIN M13   IOSTANDARD LVCMOS33 }        [get_ports { rf_ra[2]       }];
set_property -dict { PACKAGE_PIN R15   IOSTANDARD LVCMOS33 }        [get_ports { rf_ra[3]       }];
set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 }        [get_ports { rf_ra[4]       }];
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 }        [get_ports { sel_display[0] }];
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 }        [get_ports { sel_display[1] }];
set_property -dict { PACKAGE_PIN R13   IOSTANDARD LVCMOS33 }        [get_ports { sel_display[2] }];

set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 }        [get_ports { dmem_we        }];

set_property -dict { PACKAGE_PIN K13   IOSTANDARD LVCMOS33 }        [get_ports { led_value[0]   }];
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 }        [get_ports { led_value[1]   }];
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 }        [get_ports { led_value[2]   }];
set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 }        [get_ports { led_value[3]   }];
set_property -dict { PACKAGE_PIN R10   IOSTANDARD LVCMOS33 }        [get_ports { led_value[4]   }];
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 }        [get_ports { led_value[5]   }];
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 }        [get_ports { led_value[6]   }];
set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 }        [get_ports { led_value[7]   }];

set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 }        [get_ports { sel_led[0]     }];
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 }        [get_ports { sel_led[1]     }];
set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 }        [get_ports { sel_led[2]     }];
set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 }        [get_ports { sel_led[3]     }];
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 }        [get_ports { sel_led[4]     }];
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 }        [get_ports { sel_led[5]     }];
set_property -dict { PACKAGE_PIN K2    IOSTANDARD LVCMOS33 }        [get_ports { sel_led[6]     }];
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 }        [get_ports { sel_led[7]     }];