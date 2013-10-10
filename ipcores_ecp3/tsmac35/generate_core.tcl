
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

set Para(ProjectPath) "/home/greg/projects/trbnet/gbe2_ecp3/ipcores_ecp3/tsmac35"
set Para(ModuleName) "tsmac35"
set Para(lib) "/home/greg/trispeed_mac_v3.5/lib"
set Para(CoreName) "Tri-Speed Ethernet MAC"
set Para(arch) "ep5c00"
set Para(family) "latticeecp3"
set Para(Family) "latticeecp3"
set Para(design) "VHDL"
set Para(install_dir) "/opt/lattice/diamond/1.4.2.105/bin/lin/../.."
set Para(Bin) "/opt/lattice/diamond/1.4.2.105/bin/lin"
set Para(SpeedGrade) "Para(spd)"
set Para(FPGAPath) "/opt/lattice/diamond/1.4.2.105/bin/lin/../../ispfpga/bin/sol"

lappend auto_path "/home/greg/trispeed_mac_v3.5/gui"

lappend auto_path "/home/greg/trispeed_mac_v3.5/script"
package require Core_Generate

lappend auto_path "/opt/lattice/diamond/1.4.2.105/tcltk/lib/ipwidgets/ispipbuilder/../runproc"
package require runcmd


set Para(result) [GenerateCore]
