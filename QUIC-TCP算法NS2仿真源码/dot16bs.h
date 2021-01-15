#ifndef DOT16BS_HDR
#define DOT16BS_HDR

// Author:  Roshni Srinivasan
// File:        dot16bs.h
// Written: 09/21/2004 (for ns-2.26)
// Modified by Qingwen Liu 07/11/2005 (for ns2-2.28) 

#include <parameters.h>

#include <string.h>
#include "queue.h"
#include "../routing/address.h"
 


//#define MAX_EXPECTED_ARRIVAL_TIME 

/* SNR to MCS table for ITU VehA @ 60km/hr for IEEE 802.16 */
/*
const float snr_to_rate[NUM_RATE_OPTIONS][2] = {
    {1.03,  0.1667},
    {3.01,  0.25},
    {6.13,  0.50},
    {10.24,  1},
    {16.11,  2},
    {20.67,  3},
    {25.13,  4},
    {27.77,  4.5},
};
*/

/*
% Row i = MCS option i+1
% Column 1: SNR in dB
% Column 2: Throughput per slot = number of data bits per slot * 
%                                ratio of data to parity bits
% Column 3: ratio of data to parity bits


const float snr_to_rate[NUM_RATE_OPTIONS][3] = {
    {1.03, 6*8/(2*100.8e-6)/6, 0.1667},
    {3.01, 6*8/(2*100.8e-6)/4, 0.25},
    {6.13, 6*8/(2*100.8e-6)/2, 0.50},
    {10.24, 6*8/(2*100.8e-6), 1},
    {16.11, 12*8/(2*100.8e-6), 2},
    {20.67, 18*8/(2*100.8e-6), 3},
    {25.13, 24*8/(2*100.8e-6), 4},
    {27.77, 27*8/(2*100.8e-6), 4.5},
};
*/


/*float snr_to_rate[NUM_RATE_OPTIONS][3] = {
    {1.03, 6*8/6, 0.1667},// 1/6
    {3.01, 6*8/4, 0.25},//  1/4 
    {6.13, 6*8/2, 0.50},//  1/2
    {10.24, 6*8, 1},    //
    {16.11, 12*8, 2},
    {20.67, 18*8, 3},
    {25.13, 24*8, 4},
    {27.77, 27*8, 4.5},
};*/

/*1.QPSK (2 bits/symbol) + CTC w/ coding rate 1/12

2. QPSK (2 bits/symbol) + CTC w/ coding rate 1/8

3. QPSK (2 bits/symbol) + CTC w/ coding rate 1/4

4. QPSK (2 bits/symbol) + CTC w/ coding rate 1/2

5. 16QAM (4 bits/symbol) + CTC w/ coding rate 1/2

6. 16QAM (4 bits/symbol) + CTC w/ coding rate 3/4

7. 64QAM (6 bits/symbol) + CTC w/ coding rate 2/3

8. 64QAM (6 bits/symbol) + CTC w/ coding rate 3/4

Given bandwidth 1Hz and slot duration 1 sec, then the capacity_bytes are: 
1. (1/6)/8, 2. (1/4)/8, 3. (1/2)/8, 4. 1/8, 5. 2/8, 6. 3/8, 7. 4/8, 8. 4.5/8. */
float snr_to_rate[NUM_RATE_OPTIONS][3] = {
    {1.03,  0.0208333, 0.1666667}, //QPSK       1/12 = 1/6
    {3.01,  0.03125,     0.25},   //QPSK       1/8 = 1/4
    {6.13,  0.0625,      0.50},   //QPSK    1/4 = 1/2
    {10.24, 0.125,       1.0},       //QPSK    1/2  = 1   
    {16.11, 0.25,        2.0},      //16QAM 1/2  = 2
    {20.67, 0.375,       3.0},      //16QAM 3/4  = 3
    {25.13, 0.5,         4.0},      //64QAM 2/3 = 4
    {27.77, 0.5625,      4.5},    //64QAM 3/4  = 4.5
};




class Dot16BS : public Queue {
    public:
                
    Dot16BS();
    int command(int argc, const char*const* argv);

    protected:
    
    void enque(Packet*);
    
    Packet* deque();
    
    Packet* opportunistic_scheduler();
    Packet* round_robin_scheduler();
    
    //void Update_Metric_Stats(int sel_user);
    void Check_New_Trial();
    
    void dump_results();
    
    void Genarate_SNR_values();
    
    void Record_Sched_Stat(int sel_queue, float sel_rate);

    void Record_Results_PF();
	Packet* PktGen();

    PacketQueue* q_[NUM_BS_QUEUES];
    
    PacketQueue* q_newframe;
        
    int sel_queue;  /* Index of selected queue in a round (-1 is invalid) */
    float sel_rate;   /* selected scheduled rate */   
    int deq_turn_;  /* Queue index for round robin scheduling */
    
    int tokens[NUM_BS_QUEUES];
    
    /* Types of Schedulers available */
    enum sched_types {RANDOM, 
                                        ROUND_ROBIN, 
                                        OPPORTUNISTIC};
    int sched_type_;

    /* Flavors of opportunistic scheduling available */
    enum sched_modes {MAX_SNR,
                                        MAX_RELATIVE_SNR,
                                        PROPORTIONAL_FAIR,
                                            RATE_FAIR};
    int sched_mode_;
    double lambda_sched_;                    // Lagrangian multiplier for P.F.
    int qmax; /*maximum queue size */

    int num_sched_slots[NUM_BS_QUEUES];    // Number of slots scheduled
    int total_sched_rate[NUM_BS_QUEUES];   // Total scheduled rate in frames
    int total_credit_rate[NUM_BS_QUEUES];  // Total potential scheduled rate
    double last_sched_time[NUM_BS_QUEUES]; // Time when last scheduled

    int num_pkts_tx[NUM_BS_QUEUES];        // No. of packets transmitted
    int num_bytes_tx[NUM_BS_QUEUES];        // No. of bytes transmitted
    
    float snr_dB_value[Num_Trial][Num_User][Num_Slot];  // matrix for snr (dB) values  
    float NominalSINRdB[Num_User][Num_Trial];           // matrix for nominal sinr (dB) values
    float sched_stat[Num_Trial][Num_Slot][9];           // matrix for scheduled statistics
  
    int trial_index, slot_index, user_index;           // indice of trial, slot and user
    
    double avg_thrput[NUM_BS_QUEUES];    // average throughput for proportional fair scheduler
    float avg_thrput_record[Num_Trial][Num_User][Num_Slot];  // average throughput for recording
    
    int flag_fragment[NUM_BS_QUEUES];    // Flag of fragmentation 
    int fragment_bytes_inqueue[NUM_BS_QUEUES];    // Fragment (bytes) left in queue
    
    int flag_newframe;      // Flag of new frame 
    
    int capacity_bytes[NUM_BS_QUEUES];    // Capacity in bytes
    int fragment_inqueue[NUM_BS_QUEUES];    // Capacity in bytes
    
    int flag_startframe; // Flag of starting a new frame   
    int slot_index_last; // Last slot index to check if the increment of slot index is one
    
    int num_sched_pkt[NUM_BS_QUEUES];    // Num of scheduled packets

    int capacity_bytes_deq_turn_;

    float metric_record[Num_Trial][Num_User][Num_Slot];  // recorded metric 
    int capacity_record[Num_Trial][Num_User][Num_Slot];  // recorded capacity 
    int mode_record[Num_Trial][Num_User][Num_Slot];  // recorded mode selection 
    float metric[NUM_BS_QUEUES]; // metric of queue for PROPORTIONAL_FAIR scheduler 
    int virtual_pkt_enqued_indicator;
	double expected_arrival_time;
	int Check_Slot_Start_Time;
	double Prev_Slot_Time;
    double bandwidth_;
    double doppler_;
	int  NumOfSlots_;
	double SlotDuration_;
	int pktsz_;
	int NewAlg_;
	int ns2busy_;
	double record_interval_;
	double last_record_time_;
	int GenerateSNR_;
};

#endif







