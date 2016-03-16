
io.write("Please specify host file: ")
io.flush()
infile = io.read()

function dofile(filename)
	local f = assert(loadfile(filename))
	return f()
end

dofile(infile)
