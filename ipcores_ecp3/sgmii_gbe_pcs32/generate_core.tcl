
#!/usr/local/bin/wish

set Para(cmd) ""
if ![catch {set temp $argc} result] {
    if {$argc > 0} {
        for {set i 0} {$i < $argc} {incr i 2} {
            set temp [lindex $argv $i]
            set temp [string range $temp 1 end]
            lappend argv_list $temp
            lappend value_list [lindex $argv [expr $i+1]]
        }
        foreach argument $argv_list value $value_list {
            switch $argument {
                "cmd" {set Para(cmd) $value;}
            }
        }
    }
}

set Para(ProjectPath) "/home/greg/projects/trbnet/gbe2_ecp2m/ipcores/sgmii_gbe_pcs32"
set Para(ModuleName) "sgmii_gbe_pcs32"
set Para(lib) "/home/greg/sgmii_gbepcs_v3.4/lib"
set Para(CoreName) "SGMII/Gb Ethernet PCS"
set Para(family) "latticeecp2m"
set Para(Family) "ep5m00"
set Para(design) "VHDL"

lappend auto_path "/home/greg/sgmii_gbepcs_v3.4/gui"

lappend auto_path "/home/greg/sgmii_gbepcs_v3.4/script"
package require Core_Generate

lappend auto_path "/opt/lattice/ispLEVER8.1/isptools/ispcpld/tcltk/lib/ipwidgets/ispipbuilder/../runproc"
package require runcmd

set Para(install_dir) "/opt/lattice/ispLEVER8.1/isptools/ispcpld/tcltk/lib/ipwidgets/ispipbuilder/../../../../.."

set Para(result) [GenerateCore]
