
import csv, sys, getopt

def main(argv):
	infile='placeholder'
	try:
		args = getopt.getopt(argv,"hi:o",["file="])
	except getopt.GetoptError:
		print 'hostchecker.py -i <hosts file>'
	sys.exit(2)

	for arg in opts:
		if opt in ("-f","--file"):
			inifile = arg
		elif opt == '-h' or opt=='':
			print 'hostchecker.py -i <hosts file>'

print infile
	
with open(infile, 'rb') as f:
  reader = csv.reader(f)
  hostsList = list(reader)

print hostsList

