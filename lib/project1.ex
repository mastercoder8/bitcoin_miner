defmodule Bitcoin do
  def main(args) do
    if(length(args)<1) do
          IO.puts("Usage :  ./project1 zeros_count\n\t ./project1 <server_ip>")
          exit(0)
    end
        args
        |> parser 
    end

    def parser([first | _ ]) do
        # {:ok, [server_ip | _]} = :inet.getif()
        if first == nil do

        end
        {:ok, ifs} = :inet.getif()
        ip_adds = Enum.map(ifs, fn {ip, _broadaddr, _mask} -> ip end)
        [local_ip | _] = Enum.filter(Enum.map(ip_adds, fn x -> to_string(:inet.ntoa(x)) end), fn x -> "192.168.99.1"!=x && "127.0.0.1"!=x end)
        # local_ip = ["192.168.0.75"]
        IO.puts "Input Arg: #{first}"
        if String.contains?(first, ".") do
            #IP input
            IO.puts("Server IP: #{first}")
            IO.puts("Starting worker")
            Worker.connect(first, local_ip)
        else
            IO.puts("Starting Server: #{local_ip}")
            Server.start(local_ip, first)
        end
    end
end

defmodule Server do
	@name "jaya0chandra0"
	@string_count 1
	@length 15
	@ufid "saibandi;"
	@cookie "choco"
  # @zero_count 4

	def start(server_ip, zero_count) do
        IO.inspect(self())
        _pid = spawn(__MODULE__, :work_local, [self()])

        machine = @name <> "@" <> server_ip
        Node.start(:"#{machine}")
        IO.inspect(Node.set_cookie :"#{@cookie}")
        IO.inspect(:global.register_name(@name, self()))
        IO.puts("Global name #{inspect :global.whereis_name(@name)}")
        allocator(elem(Integer.parse(zero_count),0))
	end

	def work_local(server_pid) do
        IO.puts("Starting local workers")
        Worker.run_workers(server_pid)
    end

	def allocator(zero_count) do
		receive do
			{:ready, pid} -> 
				list = generate_random_strings(@string_count)
				send pid, {:ok, list, zero_count, pid} #IO.puts(~s{[#{username}'s client] - #{msg}})
			{:answer, pid, bitcoins} ->
				Enum.each(bitcoins, fn(coin) -> IO.puts(~s{#{elem(coin,0)}\t#{elem(coin,1)}}) end)
				list = generate_random_strings(@string_count)
				send pid, {:ok, list, zero_count, pid}
		end
		allocator(zero_count)
	end
	
	defp generate_random_strings(count) do
       Enum.map(1..count, fn(_x) -> random_string() end)
  end

  # def make_unique_string() do
  #     generated = random_string()
  #     if Enum.member?(bitcoin_strings, generated) do
  #       make_unique_string()
  #     else
  #       bitcoin_strings = [generated | bitcoin_strings]
  #       generated
  #     end
  # end
	
	defp random_string() do
        @ufid <> (:crypto.strong_rand_bytes(@length) |> Base.url_encode64 |> binary_part(0, @length))
    end
end


defmodule Worker do
	@name "jaya0chandra0"
  @cookie "choco"

	def spawn_process(server_pid) do
		pid = spawn(__MODULE__, :miner, [server_pid])
		send server_pid, {:ready, pid}
	end

  def wait(sname) do
      :global.sync()
      if sname == :undefined do 
          # IO.inspect(:global.whereis_name(@name))
          wait(:global.whereis_name(@name))
      end
  end

  def connect(server_ip, local_ip) do # One time Make connection 
        server_machine = @name <> "@" <> server_ip
        IO.puts("Connecting to #{server_machine}")
        machine = "Client"<>"#{:rand.uniform(1000)}" <> "@" <> local_ip #List.to_string(local_ip)
        IO.inspect(Node.start(:"#{machine}"))
        Node.set_cookie :"#{@cookie}"
        if Node.connect(:"#{server_machine}") == false do
          IO.puts("Unable to connect to #{server_machine}")
          exit(0)
        end
        IO.puts("Connected to #{machine}")
        IO.inspect(Node.list)
        wait(:global.whereis_name(@name))
        # Connected Now, Run the Workers
        run_workers(:global.whereis_name(@name))        
        server_status(server_machine, Node.connect(:"#{server_machine}"))
  end

  def run_workers(server_pid) do
      nprocessors = :erlang.system_info(:logical_processors) * 100
      for _x <- 1..nprocessors do # Create as many processes as cores
        spawn_process(server_pid) #connect("192.168.0.75", "192.168.0.75")
      end
  end

  def server_status(server_machine, status) do
    if false==status do
       IO.puts("Server Disconnected!!")
       exit(0)
    end
    server_status(server_machine, Node.connect(:"#{server_machine}"))
  end

	def miner(server_pid) do
		receive do
			{:ok, list, zero_count, pid} ->
				bitcoins = get_valid_bitcoins(list, zero_count) #Fix the hard coding
				send server_pid, {:answer, pid, bitcoins}
				miner(server_pid)
			:disconnect ->
				exit(0)
		end	
	end
	
	def get_valid_bitcoins(string_list, zero_count) do
        Enum.map(string_list, fn(x) -> {x, sha256(x)} end )
        |> Enum.filter(fn(bitcoin) ->  String.starts_with?(elem(bitcoin, 1), String.duplicate("0", zero_count)) end)
    end
	
	def sha256(str) do 
        Base.encode16(:crypto.hash(:sha256, str ))
    end
end