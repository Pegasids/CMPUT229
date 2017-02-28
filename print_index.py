import sys
import ast


# print index in format of 
# term1      docID:pos1,pos2;docID:pos1,pos2;
# term2      docID:pos1,pos2;docID:pos1,pos2;
def print_index(f):
	
	try:
		content = f.readline()
		# convert a string representation of a Dictionary to a dictionary
		inverted = ast.literal_eval(content)
		
		# print the dictionary in the correct format
		# process each term
		for word in inverted:
			# print the term
			print(word + "\t", end="")
			# process each document ID of a term
			for docID in inverted[word]['postings']:
				first = True		
				# print the document ID 
				print(docID+":", end="")
				# process each position of a document ID
				for pos in inverted[word]['postings'][docID]['pos']:
					# print the position
					if first:
						print(str(pos), end="")	
						first = False
					else:
						print(","  + str(pos), end="")
				print(";", end="")
					
			print("\n")
	# Error. Something gone wrong.
	except: 
		print("Error! Incorrect index file.")	
		
			

# open the index file and call print_index()
def main(path):	
	f = open(path, encoding="utf8")
	print_index(f)
	f.close()	


if __name__ == "__main__":
	main(sys.argv[1])
