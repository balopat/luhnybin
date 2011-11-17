NumKeyedMap := Map clone do( atPutOrig := getSlot("atPut")
	atPut := method(num, value, atPutOrig(num asString, value))
	atOrig := getSlot ("at")
	at := method(num, atOrig(num asString))
	keysSorted := method(keys map (v, v asNumber) sort)
	subSet := method (pos, size, 
		newMap := NumKeyedMap clone
		keysSorted foreach (i, v, if (i between (pos,pos+size-1), newMap atPut(v, at(v))))
		newMap
	)	
)

isBlockChar := method(ch, 
	"- 0123456789" contains(ch)
)


isDigit := method (ch, 
	ch between (48,57)
)

digit := method (ch, 
	ch asCharacter asNumber
)


getNumberBlocks := method ( inputString,
	block := NumKeyedMap clone
	numberBlocks := list()
        inputString foreach (i, v, if ( isBlockChar(v) ) then (
							if (isDigit(v), block atPut(i, digit(v))) 
						) else (
							if (block size >= 14, numberBlocks push(block))
		                                        block := NumKeyedMap clone
						)
	)
	if (block size >= 14, numberBlocks push(block))
	numberBlocks	
)


luhnCheckSumOK := method (block, 
        checkSum := 0
        block keysSorted reverse foreach (i, v,
                ( block at(v) * (i%2 + 1)) asString foreach (d,
                                                                checkSum = checkSum + digit(d) 
                                                              )
        )
        checkSum = checkSum % 10
        checkSum == 0
)


listLargestZeroChecksumSubSet := method(nkMap, 
	results := list()
	for (mapSize, 16, 14, -1, 
		for (pos, 0, (nkMap size)-mapSize, 
			candidate := nkMap subSet(pos, mapSize)
			if (luhnCheckSumOK(candidate), results push(candidate); pos = pos + mapSize)
		)
	)
	results
)

luhnCheck := method(line, 
	out := line
	toMask := NumKeyedMap clone
	getNumberBlocks(line) foreach (v, listLargestZeroChecksumSubSet(v) foreach(m, toMask mergeInPlace (m)))
	toMask keysSorted foreach (pos, out atPut(pos, 88))
	out
)


stdIn := File standardInput
lines := stdIn readLines
lines foreach (i, line, write(luhnCheck(line),"\n"))

