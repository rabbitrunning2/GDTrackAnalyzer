require_relative 'analyzer.rb'
require_relative 'screen.rb' 

class Main
	def initialize
		Analyzer.new
		Screen.new("Thank you for using this tool.")
	end
end

Main.new