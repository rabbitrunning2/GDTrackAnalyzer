require 'plist'
require 'csv.rb'

class Analyzer

	def initialize
		@result = Plist::parse_xml('GratefulDead.xml')
		@song_count = 0
		@rating_count = 0
		
		@name_count = Hash.new
		@year_count = Hash.new
		@album_count = Hash.new
		@composer_count = Hash.new
		@artist_name = Hash.new
		
		@song_ratings = Hash.new
		@year_ratings = Hash.new
		@album_ratings = Hash.new
		@composer_ratings = Hash.new
		
		generate_files
		#comparative_values
	end

	def generate_files
		value_count(@year_count, 'Year')
		ratings_aggregator(@year_ratings, @year_count, 'Year')
		hash_to_csv(hash_sort(@year_ratings), 'GDYearRatings')
		
# 		value_count(@name_count, 'Name')
# 		ratings_aggregator(@song_ratings, @name_count, 'Name')
# 		hash_to_csv(@song_ratings, 'GDSongRatings')
# 		
# 		value_count(@composer_count, 'Composer')
# 		ratings_aggregator(@composer_ratings, @composer_count, 'Composer')
# 		hash_to_csv(@composer_ratings, 'GDComposerRatings')
# 		
# 		value_count(@album_count, 'Album')
# 		ratings_aggregator(@album_ratings, @album_count, 'Album')
# 		hash_to_csv(@album_ratings, 'GDAlbumRatings')
		
	end
	
	#counts all tracks in the file.
	#returns song count value.
	def track_count
		@result['Tracks'].each do
			@song_count +=1
		end
		@song_count
	end
	
	#TODO method to compare ratings for songs by Artist.
	#OR any two separate Hashes as currently designed.
	def comparative_values
		@result['Tracks'].each do |key, value|
			if @artist_name.has_key?('Artist') and !@name_count.empty?
				@artist_name[value['Artist']] = @name_count
			end
		end
	end
	
	#Calculates the true average of the ratings of a Hash
	#hash_one is the hash with the ratings
	#hash_two contains the total count of the measured field to use for division
	#to get average.
	#TODO make sure hash with total exists.
	def ratings_calculation(hash_one, hash_two)
		hash_one.each do |key, value|
			if hash_one.has_key?(key)
				average_rating = (hash_one.fetch(key).to_f/hash_two.fetch(key))/20
				hash_one.store(key, average_rating)
			end
		end
		#print_song_ratings(hash_one)
		#hash_to_csv(hash_one, "GDYearRatings")
	end
	
	#Method converts Hash to a csv file.
	#takes in the hash and the name you want for the file.
	def hash_to_csv(hash, name)
		CSV.open(name+".csv", "wb") {|csv| hash.to_a.each {|elem| csv << elem}}
	end
	
	#All Purpose method to add up occurrences of any given value
	#in the xml document. 
	def value_count(hash, value_name)
		@result['Tracks'].each do |key, value|
			if hash.has_key?(value[value_name])
				hash[value[value_name]] += 1 
			else
				hash[value[value_name]] = 1 
			end
		end
		#print_song_ratings(hash)
	end
	
	#General purpose rating method.
	def ratings_aggregator(hash_one, hash_two, value_name)
		@result['Tracks'].each do |key, value|
				if hash_one.has_key?(value[value_name])
					hash_one[value[value_name]] += value['Rating']
				else
					hash_one[value[value_name]] = value['Rating']
				end
		end
		ratings_calculation(hash_one, hash_two)
	end	
	

	#This counts the average rating of all Tracks
	def all_song_rating_average
		track_count
		@result['Tracks'].each do |key, value|
			@rating_count += value['Rating'] 
		end
		#puts "The average rating of all songs is: #{(@rating_count.to_f/@song_count)/20}"
		@rating_count
	end
	
	def hash_sort(hash)
		hash.sort{|a,b| a[1]<=>b[1]}.reverse.each
	end
	
	#Formatted print for values without any language.
	def print_song_ratings(hash)
		size = hash.length
		hash.sort{|a,b| a[1]<=>b[1]}.reverse.first(size).each { |elem|
			puts "#{elem[1]} => #{elem[0]}"
		}
	end
	
	#Formatted print with sentence structure
	def print_hash_by_descending_value(hash, string_id)
		hash.sort{|a,b| a[1]<=>b[1]}.reverse.first(100).each { |elem|
			if (elem[1] > 1)
  			puts "There are #{elem[1]} songs #{string_id}: #{elem[0]}"
  			end
  			if (elem[1] == 1)
  			puts "There is #{elem[1]} song #{string_id}: #{elem[0]}"
  			end
		}
	end
	
end
