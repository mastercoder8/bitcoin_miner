
## Installation


BitcoinMiner [BitMiner, Server, Worker]
-------------------------------
Module: [BitMiner]
==================
Main Module to parse arguments and control Module to start Server/Clients
Usage:
- Starts Server and Local Worker processes to mine
./project1 <number>	

- Starts Remote Client and Local Workers + connects with Server
./project1 <server_ip>

Module: [Server]
================
Generates strings, mines locally and have a process waiting for remote clients to send strings
Functions:
- start					  => Start Node, register name globally, server control 
- work_local 			  => Runs Worker processes locally 
- allocator 			  => Allocate works to processes (local/remote)
						  => Sends/Receives messages & zeros count from processes and puts it to output
- generate_random_strings => generate strings of count particular count
- random_string			  => random string generation of fixed length


Module: [Worker]
================
Spawns processes, connects to server if its a remote connection before spawning. Checks the no of cores to 
Functions:
- spawn_process 		  => Spawn a process to work & send/receive messages to/from server
- connection			  => Connect to server by createing
- run_workers			  => Run workers based on the no of cores.
- server_status		      => Checks the server status and exits if server is not reachable
- miner					  => Mines the strings to bitcoins and send valid coins 
- get_valid_bitcoins 	  => Takes strings list and converts to bitcoins, check validity
- sha256				  => string to bitcoin convertor

Analyis
========
* Starting Server & Mining coins locally reaches cumulative cpu usage to ~85%.
	- Generating one string at a time and sending for the processes to mine is the best case.
	- No Network latency so best option is with 1 string per process and 100 * #cores	
	
* Max Number of machines connected remotely to server
	- Server connected on our machine (with local machine)
	- Connected 4 working machines on the same network and was able to mine zeros_length of 6 with high speed
	- Was able to do the same by getting all the machines to storm servers
	
* For zeros_length=5, the ratio of CPU time to REAL TIME = 3.4 (Machine i7 4cores 3.16GHz).  

| String		   | Hash							      |
|--------------------------|------------------------------------------------------------------|
| saibandi;-W5c0KaUNEJakjV | 00000A731689E702FBA2E95C869B77BCD4B3BF49B4B9D75B49D680A8ED074788 |
| saibandi;i4Z0i91HUxuivu- | 00000D52F6B9D72A4ABA6D0A52EC2FA92EE814DDAC0D27C14E2A7CD31B086FC3 |

* Max bitcoins zeros length
	- Was able to Mine bitcoin zeros_length = 10 which took for 2hrs
	- Successfully able to mine zeros_length = 7, within 10min (local workers) i5 with 4 Logical Processors.    
	
	| Prefix    | String              | Hash                                                              |
	|-----------|---------------------|-------------------------------------------------------------------|
	| saibandi; | pYNysqw3Cn4hGs3     | 000000750544C060BA263FB37FD32F72BB13304C458AE9973F4B1CC2FCADB9F6 |
	| saibandi; | OM4RKHOcTJic0S7     | 000000613F49B44C235536D735F61CE6855799B24AB719494471ADEA26FD0E3C |
	| saibandi; | NbmxrNIuonIjY7S     | 000000C7BBC016B467EC8F703A261923C0D44EAD0F1A58E3CC3195238ED1AA5F |
	| saibandi; | qFwxpe98mspw4Io     | 0000005C18D6F577B37688791BDD5B7D59F4F32687C524EF5250C9A9604A7BED |
	| saibandi; | 4TQDBOkypduvzUV     | 0000006E8C92A3C8A16D3EE8322CCAADD316615DF2E414E511BDA4364A8B432D |
	
* With Multiple remote clients (2), No of strings generated to mines creates impact on performance.
	- Too many strings (~20000) => keeps the client waiting for the server to generate strings	
	  [Server stays at 100% utilization, Client has fluctuations waiting ranging from 40-60]
	- Too Few strings (~100)	=> network latency issues; too much time spent sending and receiving
	  [Server has 60-70% utilization, Client has 30-40% utilization - Under utilized]
	+ Optimal cases  (over the network)
	  - Best Multiple bitcoin mining (15000) 
	  [Server stays at 80-90% utilization, Client has almost constant 50% utilization]
	  
