# MCC (Massive Concurrent Connection)

MCC is a predictable and highly scalable network load generator used for simulating workload in IoT scenarios. It can simulate flow-level network load utilizing BSD-like socket API provided by user-level TCP/IP stack named mTCP. We have modified the mTCP package to export the network data (for Intel-based Ethernet adapters only) to the app.

### Release Notes

**V 1.1**
+ Up to generating 10 million concurrent connections on a single server
+ Fix the bug of the address pool hash on multi-cores in mtcp
+ Multi-Priority requests generator

**V 1.0**
+ Two-stage timer mechanism
+ User-level stack based
+ Shared-nothing multi-threaded model

### Prerequisites
Currently the build scripts only support lower than centos 7.8, all the prerequisite packages are already under downloads/, modify `install_dependencies.sh` and `build.sh` 
to meet your os requirements.
* boost-devel
* devtoolset-8
* cmake-3.13.5
* protobuf-3.5.0
* fmt-6.1.0

### Included directories

```bash
./    
|__apps/mcc     MCC app src files  
|__deps/        Install dir of MCC dependent libraries            
|__downloads/   MCC dependent prerequisites installation packages
|__src/         MCC lib src files
|__mtcp/        mtcp library
|__include      MCC header files
```


### Installation

#### mTCP install

```bash
$  vim /root/.bashrc
# Add two configurations at the beginning as below
  RTE_SDK= <path to mtcp>/dpdk
  RTE_TARGET=x86_64-native-linuxapp-gcc
$ source /root/.bashrc
$ cd mtcp
$ ./setup_mtcp_dpdk_env.sh
     - Press [15] x86_64-native-linux-gcc to compile the package
     - Press [18] Insert IGB UIO module to install the driver
     - Press [22] Setup hugepage mappings for NUMA systems to setup hugepages(Best input 20480 for every NUMA node with 2M hugepages, or 40 for every NUMA node with 1G hugepages.)
     - Press [24] Bind Ethernet/Baseband/Crypto device to IGB UIO module
     - Press [35] Exit Script to quit the tool
     - Press "y" Get dpdk Ethernet device name(dpdk0 for default)

$ ./configure --with-dpdk-lib=$RTE_SDK/$RTE_TARGET
* Do not mind the error report of ./check_hyperthreading.sh :No such file or directory.

$ make
```
#### MCC install
First install the dependencies:
```
$sudo ./install_dependencies.sh
```
Warning: this scripts will try to change current linux kenrel, modify it if you don't want do that.
Then build the project using the scripts:
```
$sudo ./build.sh
```
There is a `build_type` option in `build.sh` to designate build type of the project. And the built 
executable file is put in directory `$PWD/build/$build_type/`

## 10 million TCP test example

The `apps` subdirectory contains several generator apps using mcc framework, runtime options
can be viewed using `-h` option, check the code for more details.
* mcc: massive concurrent connection, simulate a large number of concurrent tcp connections scenerio, modify the payload content to get reasonable response from your server.

Example for simulate 10000000 connections, packets sending threads are 15, send payload 140 bytes, high proriaty requests ratio is 0.05

```
Testbed
CPU：Intel(R) Xeon(R) Gold 6130 CPU @ 2.10GHz
Mem：128GB
OS：CentOS Linux release 7.4.1708
Kernel：3.10.0-957.el7.x86_64
NIC：82599 10 Gigabit Dual Port Network Connection 10fb

$ vim config/mtcp.conf
rcvbuf = 256  (> receive packet length)
sndbuf = 256  (> send packet length)
max_concurrency = 800000 (> c/(smp -1))
max_num_buffers = 800000 (default equal to max_concurrency)

$ vim config/arp.conf
Add server arp lists
$ vim config/route.conf
Add server ip and dpdk Ethernet device name

#dpdk0 ip config
$ ifconfig dpdk0 192.168.94.10/16

ulimit -n 10000000
```

```bash
$ cd <path to MCC>/build/release/apps/mcc

$ ./mcc -h
App options:
  -h [ --help ]                    show help message
  --log arg (=info)                set log level
  -l [ --length ] arg (=16)        length of message (> 8)
  -c [ --conn ] arg (=1)           number of flows
  -e [ --epoch ] arg (=1)          send epoch(s)
  -b [ --burst ] arg (=1)          burst packets(b=c/e for default) 
  -s [ --setup-time ] arg (=1)     connection setup time(s)
  -w [ --wait-time ] arg (=1)      wait time before sending requests(s)
  -r [ --request-ratio ] arg (=1)  ratio of high proriaty request packet
  --log-duration arg (=10)         log duration between logs


Net options:
  --network-stack arg (=kernel) select network stack (default: kernel stack
  --ips arg (=200)              number of ips when using mtcp stack
  --dest arg (=192.168.1.1)     destination ip

SMP options:
  --smp arg (=1)        number of threads (default: one per CPU)
  --mode arg (=normal)  I/O mode


### Run MCC

```bash
$ ./mcc -c 10200000 -b 170000 -l 140 -e 60 -w 30 -s 60 -r 0.05 --smp 16 --network-stack mtcp --dest 192.168.93.100
```

### Quit MCC
```bash
$ ^Ctrl+C
#Check the process residual
$ ps –aux | grep mcc
#if the process residual
$ killall -9 mcc
```

### References
> [1] Wenqing Wu, Xiao Feng, Wenli Zhang and Mingyu Chen,"MCC: a Predictable and Scalable Massive Client Load Generator. " International Symposium on Benchmarking, Measuring and Optimizing. Springer, Cham, 2020:319-331.

### Acknowledgement
MCC is a predictable and highly scalable network load generator used for simulating workload in IoT scenarios. The version 1.1 is able to generate 10 million concurrent TCP long connections. The work was supported by the Strategic Priority Research Program of the Chinese Academy of Sciences under Grant No. XDA06010401, the National Key Research and Development Program of China under Grant No. 2016YFB1000203 & 2017YFB1001602. We appreciated project leaders, Prof. Xu Zhiwei, Prof. Chen Mingyu and Prof. Bao Yungang, for their selfless support and guidance. Wang Zhuang, Feng Xiao and Wu Wenqing are also responsible for the development of the high concurrency generator MCC.

### Contacts

The issue board is the preferred way to report bugs and ask questions about MCC or contact Zhang Wenli(zhangwl at ict.ac.cn).
