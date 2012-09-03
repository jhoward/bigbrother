GEN=BigBrotherMsg.java BigBrotherCmd.java Constants.java

all: bigbrother.jar

DuplicatePacketFilter.class: ../../../include/DuplicatePacketFilter.java
	javac ../../../include/DuplicatePacketFilter.java -d .

bigbrother.jar: BigBrother.class
	jar cfm bigbrother.jar Manifest.txt *.class

BigBrotherMsg.java: ../../include/BigBrother.h
	mig -target=null -java-classname=BigBrotherMsg java ../../include/BigBrother.h bigbrother -o $@

BigBrotherCmd.java: ../../include/BigBrotherCmd.h
	mig -target=null -java-classname=BigBrotherCmd java ../../include/BigBrotherCmd.h bigbrothercmd -o $@

Constants.java: ../../include/BigBrother.h
	ncg -target=null -java-classname=Constants java ../../include/BigBrother.h NREADINGS DEFAULT_INTERVAL java ../../include/BigBrotherCmd.h STOP_DELUGE START_DELUGE STOP_SENSORS START_SENSORS -o $@

BigBrother.class: $(wildcard *.java) $(GEN)
	javac ../../../include/DuplicatePacketFilter.java -d .
	javac ../../../include/BigBrotherDB.java -d .
	javac *.java

clean:
	rm -f *.class $(GEN)

veryclean: clean
	rm bigbrother.jar
