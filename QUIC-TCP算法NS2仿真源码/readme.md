本项目证明了无线链路网络中基于窗口的最优拥塞控制方案的存在，并基于此提出了一类QUIC-TCP拥塞控制的方案；利用Lyapunov方法，如果在无线接入点AP处执行基于队列延迟的最大权重调度策略的话，我们从理论上证明QUIC-TCP能够全局性地收敛到最优的网络平衡点；<br />

构建了最后一跳无线的网络拓扑结构，用以进行Matlab和NS-2仿真实验，验证了所提出的QUIC-TCP算法的全局收敛性、稳定性和正确性；<br />

对比运行了TCP-Reno、TCP-Vegas、TCP-Cubic、TCP-Compound和FAST-TCP等现有成熟的拥塞控制算法，使它们在不同的调度策略（经典的轮询调度策略、最大SNR调度策略、以及基于队列长度的调度策略）下模拟仿真，并主要从吞吐率以及公平性等方面对各个算法进行评估。对于性能比较相近的QUIC-TCP和FAST-TCP两个算法，我们还对其单独进行了对比实验。实验的数值结果均可表明我们所提出的算法方案在基于IPv6的互联网环境中均比其他现有的TCP算法更具有优势；<br />

从TCP拥塞控制（网络层）与无线链路调度（链路层）的联合跨层优化入手，充分展示了一种可以提高网络拥塞控制效率的新的解决方案，并证明了其可行性与正确性。<br />

仿真环境：linux(ns-allinone-2.35)<br />

源码文件如下：<br />
41.tcl		——是代码在ns2环境下的脚本，装好环境之后直接运行：ns 41.tcl<br />
dot16bs.cc	——是仿真环境中的网络拓扑结构的配置文件<br />
dot16bs.h	——是网络拓扑结构的配置文件的头文件<br />
tcp-fast.cc	——是QUIC-TCP算法的源代码文件，是在FAST-TCP的基础上构建的<br />
tcp-fast.h	——是QUIC-TCP算法的源代码头文件<br />
