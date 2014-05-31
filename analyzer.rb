require 'plist'

class Analyzer

	def initialize
		@result = Plist::parse_xml('GratefulDead.xml')
		@song_count = 0
		@rating_count = 0
		@name_count = Hash.new
		@year_count = Hash.new
		@album_count = Hash.new
		@composer_count = Hash.new
		@song_ratings = Hash.new
		@year_ratings = Hash.new
		@album_ratings = Hash.new
		@composer_ratings = Hash.new
		
		value_count(@album_count, 'Album')
		ratings_aggregator(@album_ratings, @album_count, 'Album')
	end

	#counts all tracks in the file.
	#returns song count value.
	def track_count
		@result['Tracks'].each do
			@song_count +=1
		end
		@song_count
	end
	
	#tallies number of occurrences for each uniquely named track.
	#stores in Hash with song name as key and count as value.
	def individual_track_count
		@result['Tracks'].each do |key, value|
			if @name_count.has_key?(value['Name'])
				@name_count[value['Name']] +=1
			else
				@name_count[value['Name']] = 1
			end
		end
		#print_hash_by_descending_value(@name_count, "titled")
	end
	
	#Tallies the sum of all the ratings for each uniquely named song.
	#Ratings are  stored in xml as 0-100 in 20 increments.
	#Must be divided by 20 to get 0-5 star ratings.
	def ratings_count
		@result['Tracks'].each do |key, value|
			if @song_ratings.has_key?(value['Name'])
				@song_ratings[value['Name']] += value['Rating']
			else
				@song_ratings[value['Name']] = value['Rating']
			end
		end
		ratings_calculation(@song_ratings, @name_count)
		#print_hash_by_descending_value(@song_ratings, "rated")
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
		print_song_ratings(hash_one)
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
	
	#Method to count songs per year
	def year_count
		@result['Tracks'].each do |key, value|
			if @year_count.has_key?(value['Year'])
				@year_count[value['Year']] += 1 
			else
				@year_count[value['Year']] = 1 
			end
		end
		#print_hash_by_descending_value(@year_count, "from the year")
	end
	
	#Method to count rating average per year
	def year_ratings
		@result['Tracks'].each do |key, value|
			if @year_ratings.has_key?(value['Year'])
				@year_ratings[value['Year']] += value['Rating']
			else
				@year_ratings[value['Year']] = value['Rating']
			end
		end
		ratings_calculation(@year_ratings, @year_count)
	end

	#This counts the average rating of all Tracks
	def all_song_rating_average
		track_count
		@result['Tracks'].each do |key, value|
			@rating_count += value['Rating'] 
		end
		puts "The average rating of all songs is: #{(@rating_count.to_f/@song_count)/20}"
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
