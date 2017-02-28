#
# CMPUT397 started code for programming assignment 1
#
# this module provides functions to load the inverted index
# from a file/directory/sqlite database

import sys, getopt
import math
import os
from nltk.tokenize import word_tokenize
import math


'''
Returns the inverted index

TODO: load the inverted index from disk 
	for now, returns a hard-coded one
'''

# return a dictionary of inverted indices. 
def make_inverted_index(path):
	inverted = {}
	filePathsList = []
	# iterate a given folder and store each .txt file to a list.
	for filename in os.listdir(path):
		if filename.endswith(".txt"): 
			filePathsList.append(os.path.join(path, filename))
	numOfFile = len(filePathsList)
	
	# process each file	
	for file in filePathsList:
		filename = (os.path.basename(file))
		filename = (filename.split("_"))[0]
		f = open(file, encoding="utf8")
		# process each line.
		for sentence in f:
			# tonkenized the line
			tokenizedWord = word_tokenize(sentence)
			# make a dictionary for each word and its count
			wordsAndCount = {i:tokenizedWord.count(i) for i in tokenizedWord}
			# process each word
			for word in wordsAndCount:
				# add new word to the dictionary
				if word not in inverted:
					inverted[word] = {}
					inverted[word]['df'] = 1
					inverted[word]['postings'] = {}
					inverted[word]['postings'][filename] = {}
					inverted[word]['postings'][filename]['tf'] = wordsAndCount[word]
					inverted[word]['postings'][filename]['tf-idf'] = (1 + math.log(inverted[word]['postings'][filename]['tf'], 10)) * (math.log(numOfFile/inverted[word]['df'], 10))
					inverted[word]['postings'][filename]['pos'] = tuple(sorted([i for i, item in enumerate(tokenizedWord) if item == word]))
				# word already existed
				else:
					# same word but in different document?
					if filename not in inverted[word]['postings']:
						inverted[word]['df'] += 1
						inverted[word]['postings'][filename] = {}
						inverted[word]['postings'][filename]['tf'] = wordsAndCount[word]
						inverted[word]['postings'][filename]['tf-idf'] = (1 + math.log(inverted[word]['postings'][filename]['tf'], 10)) * (math.log(numOfFile/inverted[word]['df'], 10))
						inverted[word]['postings'][filename]['pos'] = tuple(sorted([i for i, item in enumerate(tokenizedWord) if item == word]))
					# same word and same document?
					else:
						inverted[word]['postings'][filename]['tf'] += wordsAndCount[word]
						inverted[word]['postings'][filename]['tf-idf'] = (1 + math.log(inverted[word]['postings'][filename]['tf'], 10)) * (math.log(numOfFile/inverted[word]['df'], 10))
						inverted[word]['postings'][filename]['pos'] = tuple(sorted(inverted[word]['postings'][filename]['pos'] + tuple([i for i, item in enumerate(tokenizedWord) if item == word])))
						
						
		f.close()
						
	return inverted
					
		
		
	
def get_inverted_index(path):
	return make_inverted_index(path)
	
	
	
''' 
WRITE YOUR UNIT TESTS HERE
'''

def main(argv):
	#path = 'C:\\Users\\Canopy\\Desktop\\w17_a1_starter\\test\\documents'	
	
	fout = open("create_index.txt", 'w')
	fout.write(str(get_inverted_index(argv)))
	fout.close()	


if __name__ == "__main__":
	main(sys.argv[1])
