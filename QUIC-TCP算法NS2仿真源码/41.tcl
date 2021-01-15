#0:Reno;  1:Vegas;  2:Fast; 3:QUIC(0.0);  4:QUIC(0.5);  5:QUIC(1.0); 6 : QUIC(other rho values)
set TcpSchemeIndex 4
set NewCSMASwitch 1
#0:RR; 1:MSNR; 2:PFAIR; 3:QDELAY; 4:QLEN
set SchedulerIndex 3
set testRho       0.5 
#Approximately,
#for \rho = 0,  step size = [0.00004---0.0015]; 
#for \rho = 0.5, step     =  [0.005---3.0];
#for \rho = 1.0 step     =  [10---2000];

set testGamma 1.5

set CWM                     8

set use_cwmin 0
set modify_inc_cw 0
#//IIR filter coeff y = alpha*x + (1-alpha)*y.
set alpha100 10
set time_parameter 20  
# Record Procedure
proc record {} {
	global tcps ntcps
	global f    
	global queueMoniF queueMoniB
	global tcps_start tcps_stop
        global RecInterval bRTT_TCP
        global AgentType
        global PreTime SimDuration
	#get an instance of the simulator
	set ns [Simulator instance]
	

	set now [$ns now]
	#set queueF [$queueMoniF set pkts_]
	#set queueB [$queueMoniB set pkts_]
	set now0 [$ns now]
       if {$PreTime <= [expr $now0 - 50]} {
           set PreTime [ expr $PreTime + 50]
            puts "Sim.  progress: $PreTime / $SimDuration"
             
        } ;

	set rate 0

      

	for {set i 0} {$i < $ntcps} {incr i} {
		if { ($now > $tcps_start($i)) && ($now < $tcps_stop($i)) } {
                        
                         
                        set Tick  [expr [$tcps($i) set tcpTick_]]
                        set T_SRTT_BITS [expr [$tcps($i) set T_SRTT_BITS]]
                        set TimeScale [expr $Tick/pow(2,$T_SRTT_BITS)]

			set window      [expr [$tcps($i) set cwnd_]];
                        if {$AgentType == "Fast"} {
                            set avg_rtt [expr [$tcps($i) set avgRTT_]];
                            
                        } else {
			    set sRTT  [expr [$tcps($i) set srtt_]];
                            set avg_rtt   [expr $sRTT*$TimeScale]
                        }
                       
                        
                        if {$bRTT_TCP($i) > $avg_rtt} {
                           if {$avg_rtt > 0} {
                            set bRTT_TCP($i) $avg_rtt
                            }
                        }
                        if {$AgentType == "Fast"} {
                        set bRTT_TCP($i)	[expr [$tcps($i) set baseRTT_]];
                        set old_window 	[expr [$tcps($i) set avg_cwnd_last_RTT_]];
                        }
			set inst_rtt_noscale 	[expr [$tcps($i) set rtt_]];
                        set inst_rtt [expr $inst_rtt_noscale*$TimeScale]
                       	set total_pkt_num	[expr [$tcps($i) set t_seqno_]]
                        #set highest_ack	[expr [$tcps($i) set ack_]]
                        set highest_ack	[expr [$tcps($i) set ssthresh_]]
                        #largest consecutive ACK, frozen during Fast Recovery */
                        set last_consecutive_ack_ [expr [$tcps($i) set last_ack_]]
                        
                       
                        # t_seqno_
			set rate	0
			if { $avg_rtt > 0 }  {
                                 
		        	set rate	[expr $window/$avg_rtt]
			}
			if { $bRTT_TCP($i) < 9999999 } {
                                
		  		puts $f($i) "$i $now $rate $window $avg_rtt $bRTT_TCP($i) $inst_rtt  $total_pkt_num $highest_ack $last_consecutive_ack_" 
                                #puts $f($i) "$i $now $rate $bRTT_TCP($i)  $avg_rtt $old_window $window $total_pkt_num $highest_ack $last_consecutive_ack_" 
           
			}
		}
	}
        
	# Re-schedule the procedure
       
	$ns at [expr $now+$RecInterval] "record"
}
# Define 'finish' procedure (include post-simulation processes)
proc finish {} {
	global ns
	global f 
	#global TraceAll 
        #global myNAM
        global ntcps
	#$ns flush-trace
	#close $TraceAll
        for {set i 0} {$i < $ntcps} {incr i} {
            close $f($i)
        }
        #close $myNAM
        #exec nam out.nam &
        set EndTime [$ns now]
      	puts ".tcl: Simulation Finished at $EndTime sec."
	exit 0
}
#End of finish0 proc

#Wireless Nodes  Configuration
# ====================================================================== 
# Define options 
# ====================================================================== 
set val(chan)         Channel/WirelessChannel  ;# channel type 
set val(prop)         Propagation/TwoRayGround ;# radio-propagation model 
set val(ant)          Antenna/OmniAntenna      ;# Antenna type 
set val(ll)           LL                       ;# Link layer type 
set val(ifq)          Queue/DropTail/PriQueue  ;# Interface queue type 
set val(ifqlen)       2000                  ;# max packet in ifq 
set val(netif)        Phy/WirelessPhy          ;# network interface type 
set val(mac)          Mac/802_11               ;# MAC type 
set val(rp)              DSDV                  ;# ad-hoc routing protocol  DSDV AODV olsr
set val(nn)           15                     ;# number of mobilenodes 
set val(wn)        6
set val(bn)        1
global ns
#remove-all-packet-headers
#add-packet-header MPEG4 MAC_HS RLC LL Mac RTP TCP IP Common Flags

set ns [new Simulator]
$ns use-newtrace
set tracefd [open simple.tr w]
$ns trace-all $tracefd
############################
# Simulation Parameters
set PreTime 0
set SlotDuration [expr 1e-2]
set NumberofSlots [expr 1000/$SlotDuration]
set RecInterval [expr $SlotDuration*1]
set Doppler 127.777778
set BandWidth [list 10Mb]
set Num_Wireless_Flows 4
set Num_None_Wireless_Flows 0
set BaseStationQueueLimit 2000
#set ssthresh 400
set TargetQLen(0) 200
set TargetQLen(1) 200
set TargetQLen(2) 200
set TargetQLen(3) 200
set True_pktSize 200
set pktSize [expr $True_pktSize - 40]

set RhoValue 9.0
if {$TcpSchemeIndex == 0} {
    set AgentType [list Reno]
} elseif {$TcpSchemeIndex == 1} {
    set AgentType [list Vegas]
    set pktSize [expr $True_pktSize - 0]
} elseif {$TcpSchemeIndex == 2} {
   set AgentType [list Fast] 
   set RhoValue 9.0
} elseif {$TcpSchemeIndex == 3} {
   set AgentType [list Fast] 
   set RhoValue 0.0
} elseif {$TcpSchemeIndex == 4} {
   set AgentType [list Fast] 
   set RhoValue 0.5
} elseif {$TcpSchemeIndex == 5} {
   set AgentType [list Fast] 
   set RhoValue 1.0
} elseif {$TcpSchemeIndex == 6} {
   set AgentType [list Fast] 
   set RhoValue $testRho
} else {
    puts "TCP Type Error\n"
    exit(1);
}

set GammaValue $testGamma


if {$SchedulerIndex == 0} {
    set Sched [list RR]
    Queue/Dot16BS set SchedType 1
    Queue/Dot16BS set SchedMode 0
    Queue/Dot16BS set NewAlg    0 
} elseif {$SchedulerIndex == 1} {
    set Sched [list MSNR]  
    Queue/Dot16BS set SchedType 2
    Queue/Dot16BS set SchedMode 0
    Queue/Dot16BS set NewAlg    0 

} elseif {$SchedulerIndex == 2} {
    set Sched [list PFAIR]
    Queue/Dot16BS set SchedType 2
    Queue/Dot16BS set SchedMode 2
    Queue/Dot16BS set NewAlg    0 
} elseif {$SchedulerIndex == 3} {
    set Sched [list QDELAY]
    Queue/Dot16BS set SchedType 2
    Queue/Dot16BS set SchedMode 2
    Queue/Dot16BS set NewAlg    1 
} elseif {$SchedulerIndex == 4} {
    set Sched [list QLEN]
    Queue/Dot16BS set SchedType 2
    Queue/Dot16BS set SchedMode 2
    Queue/Dot16BS set NewAlg    2
} else {
    puts "Scheduler Type Error\n"
    exit(1);
}


puts "Scheduler Type = $Sched;    Agent Type = $AgentType; Packet Size = $True_pktSize\n"


Queue/Dot16BS set BandWidth $BandWidth 
Queue/Dot16BS set Doppler $Doppler
Queue/Dot16BS set NumberOfSlots $NumberofSlots
Queue/Dot16BS set SlotDuration  $SlotDuration
Queue/Dot16BS set RecordInterval $RecInterval
Queue/Dot16BS set BaseStationQueueLimit $BaseStationQueueLimit
Queue/Dot16BS set pktsz  $True_pktSize
Queue/Dot16BS set GenerateSNR  0
##########################

#End of predef

# Create Sources and Start & Stop times
#set NumberofSlots 10000
set starttime 0.0
set SimDuration [expr ($NumberofSlots)*$SlotDuration]
#puts "Simulation time = $SimDuration seconds" 

set ntcps    [expr  $Num_Wireless_Flows+$Num_None_Wireless_Flows];

# Name Of Record File:
set flow [list _flow_]
set gam [list _Gamma]
set rh [list _rho]
set sw [list _switch]
for {set i 0} {$i < $ntcps} {incr i} {
     if {$AgentType == "Fast"} {
       set Name($i) $AgentType$gam$GammaValue$rh$RhoValue$Sched$sw$NewCSMASwitch$flow$i.dat
     } else {
       set Name($i) $AgentType$Sched$sw$NewCSMASwitch$flow$i.dat
     }
    set f($i) [open $Name($i) w]
    set bRTT_TCP($i) 9999999
}

#creat Trace-File
if {$AgentType == "Fast"} {
       set TraceFileName $AgentType$gam$GammaValue$rh$RhoValue$Sched.tr
       puts "Gamma = $GammaValue, Rho = $RhoValue"
       #puts "Target Queue Length Per Flow = $TargetQLen"
} else {
    set TraceFileName $AgentType$Sched.tr
}

#set TraceAll [open $TraceFileName w]
#$ns trace-all $TraceAll

# Create a NAM trace file
#set myNAM [open out.nam w]
#$ns namtrace-all $myNAM



set tcps_start(0) [expr (0.0*$NumberofSlots)*$SlotDuration]
set tcps_stop(0)  [expr (1.0*$NumberofSlots)*$SlotDuration]
set tcps_start(1) [expr (0*$NumberofSlots)*$SlotDuration]
set tcps_stop(1)  [expr (1*$NumberofSlots)*$SlotDuration]
set tcps_start(2) [expr (0*$NumberofSlots)*$SlotDuration]
set tcps_stop(2)  [expr (1*$NumberofSlots)*$SlotDuration]
set tcps_start(3) [expr (0*$NumberofSlots)*$SlotDuration]
set tcps_stop(3)  [expr (1*$NumberofSlots)*$SlotDuration]





set finishtime $SimDuration

# set up for hierarchical routing
  $ns node-config -addressType hierarchical
  AddrParams set domain_num_ 2          
  lappend cluster_num 1 1               
  AddrParams set cluster_num_ $cluster_num
  lappend eilastlevel 6 16             
  AddrParams set nodes_num_ $eilastlevel 

# Create and configure topography (used for mobile scenarios)
set topo [new Topography]
# 1000mx1000m terrain
$topo load_flatgrid 1000 1000

# Create the "general operations director"
# Used internally by MAC layer: must create!
create-god [expr $val(nn)+$val(bn)+$val(wn)];

 #create wired nodes
  set temp {0.0.0 0.0.1 0.0.2 0.0.3 0.0.4  0.0.5 }        
  for {set i 0} {$i < $val(wn) } {incr i} {
      set W($i) [$ns node [lindex $temp $i]]
  } 

 
#-------------------------Configure Nodes----------------------
$ns node-config -adhocRouting $val(rp) \
	-llType $val(ll) \
	-macType $val(mac) \
	-ifqType $val(ifq) \
	-ifqLen $val(ifqlen) \
	-antType $val(ant) \
	-propType $val(prop) \
	-phyType $val(netif) \
	-channel [new $val(chan)] \
	-topoInstance $topo \
        -wiredRouting ON \
	-agentTrace ON \
	-routerTrace ON \
	-macTrace OFF \
	-movementTrace OFF

if {$NewCSMASwitch != 0} {
#Mac/802_11 set CWMin_ $CWM
Mac/802_11 set time_para  $time_parameter
}

Mac/802_11 set switch_  $NewCSMASwitch
Mac/802_11 set use_cwmin_  $use_cwmin
Mac/802_11 set modify_inc_cw_  $modify_inc_cw
Mac/802_11 set alpha100_  $alpha100
Mac/802_11 set bandwidth_ 1.0M

#Base Station'
 $ns node-config       -wiredRouting ON
 # hier address to be used for wireless domain
set temp {1.0.0 1.0.1 1.0.2 1.0.3 1.0.4  1.0.5  1.0.6   1.0.7   1.0.8   1.0.9   1.0.10    1.0.11   1.0.12   1.0.13   1.0.14   1.0.15}  
for {set i 0} {$i < $val(bn) } {incr i} {
set BS($i) [$ns node [lindex $temp $i] ]
$BS($i)  random-motion 0
$BS($i) set X_ 0.0
$BS($i) set Y_ 0.0
$BS($i) set Z_ 0.0
}


# now create mobilenodes
$ns node-config -wiredRouting OFF
for {set i 1} {$i <= $val(nn) } {incr i} {
set node($i) [$ns node [lindex $temp   $i]]
# provide each mobilenode with hier address of its base-station
$node($i) base-station [AddrParams addr2id      [$BS(0) node-addr]] 
$node($i)  random-motion 0 ;# disable random motion
$node($i) set Z_ 0.0
}
 
for {set i 1} {$i < 4 } {incr i} {
 $node($i) set X_  [expr 150*$i  ]
 $node($i) set Y_ 0.0 
}

for {set i 4} {$i < 8 } {incr i} {
 $node($i) set X_  [expr 150*$i  - 150*4]
 $node($i) set Y_ 150.0 
}

for {set i 8} {$i < 12 } {incr i} {
 $node($i) set X_  [expr 150*$i - 150*8]
 $node($i) set Y_ 300.0 
}


for {set i 12} {$i < 16 } {incr i} {
 $node($i) set X_  [expr 150*$i-150*12 ]
 $node($i) set Y_ 450.0 
}
 
#create links between wired and BS nodes   
$ns duplex-link $W(0) $W(4) 1Mbit 5ms  DropTail 
$ns duplex-link $W(2) $W(4) 1Mbit 5ms  DropTail 
$ns duplex-link $W(4) $W(5) 1Mbit 5ms  DropTail 
$ns duplex-link $W(1) $W(5) 1Mbit 5ms  DropTail 
$ns duplex-link $W(3) $W(5) 1Mbit 5ms  DropTail 
$ns duplex-link $W(5) $BS(0) 1Mbit 5ms  DropTail 
$ns queue-limit $W(0) $W(4)   2000
$ns queue-limit $W(2) $W(4)   2000
$ns queue-limit $W(5) $W(4)   2000
$ns queue-limit $W(1) $W(5)   2000
$ns queue-limit $W(3) $W(5)   2000
$ns queue-limit $W(5) $BS(0)   2000

# setup TCP connections
for {set i 0} {$i < $ntcps} {incr i} {

    #TCP Agents:
    set tcps($i) [new Agent/TCP/$AgentType]
    $tcps($i) set fid_ $i
    $tcps($i) set prio_ 2
    $tcps($i) set window_ 20000
    $tcps($i) set packetSize_ $pktSize
    $tcps($i) set ssthresh_ 1000
    if {$AgentType == "Fast"} {
        $tcps($i) set alpha_ $TargetQLen($i)
        $tcps($i) set beta_ $TargetQLen($i)
        puts "Target Queue $i = $TargetQLen($i)"
        $tcps($i)  set gamma_ $GammaValue
        $tcps($i)  set rho_ $RhoValue
        $tcps($i)  set high_accuracy_cwnd_ 1
    }  elseif {$AgentType == "Vegas"} {
        $tcps($i) set v_alpha_ $TargetQLen($i)
        $tcps($i) set v_beta_ [expr $TargetQLen($i) + 3];
         puts "Vegas: Target Queue $i = $TargetQLen($i)"

    } 
   
    #FTP :
    set ftp($i) [new Application/FTP]
    #$ftp($i) set packetSize_ 10000
    #Attach:
    $ftp($i) attach-agent $tcps($i)
    #Sink:
    set sink($i) [new Agent/TCPSink]
    $sink($i) set fid_ $i
}



#Attaching Tcp Agents to nodes
$ns attach-agent $node(1) $tcps(0)
$ns attach-agent $node(15) $sink(0)

$ns attach-agent $node(12) $tcps(1)
$ns attach-agent $node(11) $sink(1)

$ns attach-agent $node(2) $tcps(2)
$ns attach-agent $node(13)  $sink(2)

$ns attach-agent $node(7) $tcps(3)
$ns attach-agent $node(8) $sink(3)



for {set i 0} {$i < $ntcps} {incr i} {
    $ns connect $tcps($i) $sink($i)
    $ns at $tcps_start($i) "$ftp($i) start"
    $ns at $tcps_stop($i)  "$ftp($i) stop"
}

# Run the Simulation
$ns at 0.0 "record"
$ns at $SimDuration "finish"
puts "Simulating $SimDuration Secs."

$ns run


