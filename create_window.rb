require 'tk'

class CreateWindow
	def initialize
		TK.Root.new("Track Analyzer")
		Tk.mainloop
	end
end

CreateWindow.new