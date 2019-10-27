// Define analyser's channel
// as a queue of bytes
// because we will store characters
chan input = [100] of { byte };

// Define morseEncoder's input channel
// as a queue of bytes
// because we will store characters
chan encode = [100] of { byte };

// Define the custom message types:
// DOT: Morse code's '•'
// LINE: Morse code's '▬'
// NEWLINE: standard '\n' character
// EOM: End Of Message, so that receiving proccesses know when to end
mtype = { DOT, LINE, NEWLINE, EOM };

// Define display's input channel and morseEncoder's output channel
// as a queue of mtypes because they will be encoded by the morseEncoder proccess
// according to the custom message types that we previously defined
chan sentence = [200] of { mtype };

// Define sosCheck's input channel and morseEncoder's output channel
// as a queue of groups of 3 mtypes
// because all three letters of the SOS word,
// are represented in Morse code with just three characters
chan check = [100] of { mtype, mtype, mtype };

bool sosSent = false, helpPrinted = false;

// LTL Formulae
// reassuring that whenever an 'SOS' message is encoded
// a 'HELP' message is printed immediately after
ltl sosCheckForm { [] ( sosSent -> <> helpPrinted ) };

// Main proccess
init {
	// Store the number of proccesses at the beggining
	// to be used later
	pid n = _nr_pr;

	// activate all other proccesses
	run analyser();
	run morseEncoder();
	run display();
	run sosCheck();

	// send input to the analyser proccess
	// and indirectly to all the proccesses
	// input!'H'; // test for recognised character
	// input!'E';
	// input!'L';
	// input!'L';
	// input!'O';
	// input!'S';
	// input!'!'; // test for unrecognised character
	input!'S'; // test
	input!'O'; // the
	input!'S'; // sosCheck proccess

	// Change the 'sosSent' flag to true
	sosSent = true;
	input!'\n';

	// wait for all proccesses except for init
	// to successfully end
	(_nr_pr == n);
}

// analyses the characters sended to the 'input' channel
// until a newline is received
// counts the number of characters and words received as input
proctype analyser()
{
	// initialise local variables
	// c -> received characters
	// nc -> Number of Characters counter
	// nw -> Number of Words counter
	// inword -> whether it is currently receiving a word (flag)
	byte c;
	int nc, nw;
	bool inword;

	// receive the input in a do...od loop
	// by reading each character
	do
	:: input?c ->
		if
		// if a newline is read then pipe it to the morseEncoder
		// and go to the end section of the proccess
		:: (c == '\n') ->
			encode!c;
			goto end;
		// if the received character is not a newline
		:: else ->
			// if the character is a word delimeter
			// then change the inword flag to false
			if
			:: (c == '\t') || (c == ' ') ->
				inword = false;
			// if it is neither a newline nor a word delimeter
			:: else ->
				// add +1 to the character counter
				nc++;
				// pipe the character to the morseEncoder
				encode!c;

				// if this is the first character of a word
				if
				:: !inword ->
					// add +1 to the word counter
					// change the inword flag to true
					nw++;
					inword = true;
				:: else -> skip;
				fi;
			fi;
		fi;
	od;

	// successfully terminate the proccess
	// by validating that the number of characters
	// is greater than or equal to the number of words
	// and writing to the console
	// the total number of characters
	// and the total number of words read
	end:
		assert(nc >= nw);
		printf("\nCharacters: %d, Words: %d\n", nc, nw);
}

// encodes the characters analyzed by the analyzer proccess
// into morse code and pipes the encoded message
// to the display and the sosCheck proccess
proctype morseEncoder() {
	// initialise local variables
	// c -> the received character
	byte c;

	// receive the input in a do...od loop
	// by reading each character
	do
	:: encode?c ->
		// if the character is a newline
		// go to the end section of the proccess
		if
		:: (c == '\n') -> goto end;
		:: else ->
			if
			:: c >= 'A' && c <= 'Z' ->
				if
				// if the character is not a newline
				// then encode it into Morse code
				// and pipe the encoded message to the display proccess
				// and if it is one of the three letters of the SOS word
				// also pipe it to the sosCheck proccess
				:: (c == 'A') ->
					sentence!DOT;
					sentence!LINE;
				:: (c == 'B') ->
					sentence!LINE;
					sentence!DOT;
					sentence!DOT;
					sentence!DOT;
				:: (c == 'C') ->
					sentence!LINE;
					sentence!DOT;
					sentence!LINE;
					sentence!DOT;
				:: (c == 'D') ->
					sentence!LINE;
					sentence!DOT;
					sentence!DOT;
				:: (c == 'E') ->
					sentence!DOT;
				:: (c == 'F') ->
					sentence!DOT;
					sentence!DOT;
					sentence!LINE;
					sentence!DOT;
				:: (c == 'G') ->
					sentence!LINE;
					sentence!LINE;
					sentence!DOT;
				:: (c == 'H') ->
					sentence!DOT;
					sentence!DOT;
					sentence!DOT;
					sentence!DOT;
				:: (c == 'I') ->
					sentence!DOT;
					sentence!DOT;
				:: (c == 'J') ->
					sentence!DOT;
					sentence!LINE;
					sentence!LINE;
					sentence!LINE;
				:: (c == 'K') ->
					sentence!LINE;
					sentence!DOT;
					sentence!LINE;
				:: (c == 'L') ->
					sentence!DOT;
					sentence!LINE;
					sentence!DOT;
					sentence!DOT;
				:: (c == 'M') ->
					sentence!LINE;
					sentence!LINE;
				:: (c == 'N') ->
					sentence!LINE;
					sentence!DOT;
				:: (c == 'O') ->
					sentence!LINE;
					sentence!LINE;
					sentence!LINE;
					// send the encoded message
					// to the sosCheck proccess
					check!LINE,LINE,LINE;
				:: (c == 'P') ->
					sentence!DOT;
					sentence!LINE;
					sentence!LINE;
					sentence!DOT;
				:: (c == 'Q') ->
					sentence!LINE;
					sentence!LINE;
					sentence!DOT;
					sentence!LINE;
				:: (c == 'R') ->
					sentence!DOT;
					sentence!LINE;
					sentence!DOT;
				:: (c == 'S') ->
					sentence!DOT;
					sentence!DOT;
					sentence!DOT;
					check!DOT,DOT,DOT;
				:: (c == 'T') ->
					sentence!LINE;
				:: (c == 'U') ->
					sentence!DOT;
					sentence!DOT;
					sentence!LINE;
				:: (c == 'V') ->
					sentence!DOT;
					sentence!DOT;
					sentence!DOT;
					sentence!LINE;
				:: (c == 'W') ->
					sentence!DOT;
					sentence!LINE;
					sentence!LINE;
				:: (c == 'X') ->
					sentence!LINE;
					sentence!DOT;
					sentence!DOT;
					sentence!LINE;
				:: (c == 'Y') ->
					sentence!LINE;
					sentence!DOT;
					sentence!LINE;
					sentence!LINE;
				:: (c == 'Z') ->
					sentence!LINE;
					sentence!LINE;
					sentence!DOT;
					sentence!DOT;
				fi;
				// send a NEWLINE message to both output channels
				// if the character is recognised
				check!NEWLINE,NEWLINE,NEWLINE;
				sentence!NEWLINE;
			:: else ->
				// send a NEWLINE message to both output channels
				// if the character is not recognised
				check!NEWLINE,NEWLINE,NEWLINE;
				sentence!NEWLINE;
			fi;
		fi;

	od;

	// successfully terminate the proccess
	// by sending an EOM message to both output channels
	// and printing 'Encoded' to the console
	end:
		sentence!EOM;
		check!EOM,EOM,EOM;
}

proctype display() {
	mtype m;

	do
	:: sentence?m ->
		if
		:: (m == DOT) -> printf("•");
		:: (m == LINE) -> printf("▬");
		:: (m == NEWLINE) -> printf("\n");
		:: (m == EOM) -> skip;
		:: else -> skip;
		fi;
	od;
}

// listen to morseEncoder's incoming channel
// and print 'HELP' when a 'SOS' message
// is received
proctype sosCheck() {
	// initialise the local variables
	// m1 -> message 1/3
	// m2 -> message 2/3
	// m3 -> message 3/3
	mtype m1, m2, m3;
	// s -> whether an 'S' character is received (flag)
	// o -> whether an 'O' character is received (flag)
	// exactly after an 'S' character
	bool s, o;

	// receive the encoded message in a do...od loop
	// by reading each group of 3 characters
	do
	:: check?m1,m2,m3 ->
		// if the three messages of the current message group
		// equal to the 'S' character and the previous character
		// was not an 'S' then change the 's' flag to true
		if
		:: m1 == DOT && m2 == DOT && m3 == DOT && !s ->
			s = true;
		// if the three messages of the current message group
		// equal to the 'Ο' character and the previous character
		// was an 'S' then change the 'o' flag to true
		:: m1 == LINE && m2 == LINE && m3 == LINE && s && !o ->
			o = true;
		// if the three messages of the current message group
		// equal to the 'S' character and the two previous characters
		// were 'S' and 'O' respectively then we can be sure
		// that an 'SOS' message was received
		// so print a 'HELP' message to the console
		// and change the 's' and 'o' flags to false
		:: m1 == DOT && m2 == DOT && m3 == DOT && s && o ->
			printf("\nHELP\n");

			// Change the 'helpPrinted' flag to true
			helpPrinted = true;

			s = false;
			o = false;
		// if the first of the three messages of the current message group
		// equals to the NEWLINE message then we can safely skip the current message
		:: m1 == NEWLINE ->
			skip;
		// if the first of the three messages of the current message group
		// equals to the EOM message then goto the end of the proccess
		:: m1 == EOM ->
			skip;
		fi;
	od;
}
