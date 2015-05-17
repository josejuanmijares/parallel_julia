module DummyModule

export MyType, f,longrun

type MyType
    a::Int
end

f(x) = x^2+1

function longrun(n)
	temp = 0;
	for l=0:10
		for k=0:n
			temp = temp + Int64(rand()>0.5);
		end
	end
	return temp;
end
		
println("loaded")

end
