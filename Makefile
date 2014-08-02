all: main parse solve

out: main
	./main

main:
	g++ KQkr.cpp -o main

parse:
	g++ parser.cpp -o parse

solve:
	g++ solver.cpp -o solve

clean:
	rm main parse solve out
