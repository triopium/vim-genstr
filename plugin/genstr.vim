" vim: ts=4 fdm=syntax
""ABOUT: GENERATE RANDOM STRINGS
"TODO:"
"1. Maybe better random usind /dev/urandom
"2. shaped probabilities distribution
"3. Paragraph word length ranges, letters frequencies

"GENERATE RANDOM NUMBER LIST FROM RANGE:"
function! genstr#NumVecRand(lbound,ubound,count)
	let l:bashc="shuf -ri " . a:lbound . "-" . a:ubound . " -n" . a:count
	let l:randnumber=systemlist(l:bashc)
	return l:randnumber
endfunction
"" Test: genstr#NumVecRand
""let nums=genstr#NumVecRand(0,36,100)
""echo nums
""let nums=genstr#NumVecRand(0,36,1)
""echo nums

let g:genstr#CharspacesList={
	\ 'alpha':'abcdefghijklmnopqrstuvwyz',
	\ 'ALPHA':'ABCDEFGHIJKLMNOPQRSTUVWYZ',
	\ 'aZ':'abcdefghijklmnopqrstuvwyzABCDEFGHIJKLMNOPQRSTUVWYZ',
	\ 'czech':'aábcčdďeéěfghchiíjklmnňoópqrřsštťuúůvwxyýzž',
	\ 'CZECH':'AÁBCČDĎEÉĚFGHCHIÍJKLMNŇOÓPQRŘSŠTŤUÚŮVWXYÝZŽ',
	\ 'Czech':'AaábcčdďeéěfghchiíjklmnňoópqrřsštťuúůvwxyýzžÁBCČDĎEÉĚFGHCHIÍJKLMNŇOÓPQRŘSŠTŤUÚŮVWXYÝZŽ1234567890',
	\ 'dnum':'1234567890',
	\ 'aZ10':'abcdefghijklmnopqrstuvwyzABCDEFGHIJKLMNOPQRSTUVWYZ1234567890',
	\ 'greek':'δΔ'}
""echo strchars(g:genstr#CharspacesList.czech)
""echo strdisplaywidth('	')
""echo strchars('	')

"SUBSET CHARSPACE FROM CHARSPACES:
function! genstr#Charspaces(charspace)
	"CHAR SPACE DEFININITON"
	let l:def_charspaces=g:genstr#CharspacesList
	let l:chspaces=split(a:charspace,',')
	let l:newchspace=''
	for l:i in l:chspaces
		let l:newchspace.=l:def_charspaces[l:i]
	endfor
	return l:newchspace
endfunction
"" Test: genstrCharspaces
""echo genstr#Charspaces('alpha,ALPHA,aZ')

"GENERATE RANDOM STRINGWORD OF SPECIFIED LENGTH FROM CHARSPACE:"
function! genstr#StringRand(charspace,length)
	let l:outstr=''
	let l:spacelength=strchars(a:charspace)-1
	let l:nums=genstr#NumVecRand(0,l:spacelength,a:length)
	for l:i in l:nums
		""strcharpart takes index starting at 0
		let l:outstr.=strcharpart(a:charspace,l:i,1)
	endfor
	return l:outstr
endfunction
"Test: genst#randstrword
"let nums=genstr#NumVecRand(0,36,100)
"echo nums
""echo genstr#StringRand('ěščřžýáí',10)
""echo genstr#StringRand(g:genstr#CharspacesList.czech,100)

"GENERATE SPAN WORD FROM CHARSPACE:"
function! genstr#StringSpan(charspace,length)
	let l:spacelength=strchars(a:charspace)
	if a:length > l:spacelength
		let l:quot=a:length/l:spacelength
		let l:mod=a:length%l:spacelength
		let l:rstring=repeat(a:charspace,l:quot)
		let l:rstring.=strcharpart(a:charspace,0,l:mod)
	elseif a:length == l:spacelength
		let l:rstring=a:charspace
	else
		let l:rstring=''
		let l:mod=a:length%l:spacelength
		let l:rstring.=strcharpart(a:charspace,0,l:mod)
	endif
	return l:rstring
endfunction
"Test: genstr#StringSpan
""echo genstr#StringSpan("abcdefg",10)
""echo genstr#StringSpan(g:genstr#CharspacesList.czech,100)
""echo genstr#StringSpan(g:genstr#CharspacesList.aZ10,100)
""echo genstr#StringSpan(g:genstr#CharspacesList.dnum,10)

""SPLIT STRING TO VECTOR BY ATOM LENGTHS:
function! genstr#StringSplitAtomLengths(string,lengths)
	let l:spvec=[]
	let l:string=a:string
	for l:i in a:lengths
		let l:patts='.\{' . l:i . '}\ze'
		let l:patte='.\{' . l:i . '}\zs.*'
		call add(l:spvec,matchstr(l:string,l:patts))
		let l:string=matchstr(l:string,l:patte)
	endfor
	return l:spvec
endfunction
"" let str=genstr#StringSpan(g:genstr#CharspacesList.czech,100)
"" echo str
"" let nums=genstr#NumVecRand(1,40,10)
"" echo nums
""echo genstr#StringSplitAtomLengths('1234567890abcdefghijklmn',[3,3,9])

""SPLIT STRING TO VECTOR LENGTH:
function! genstr#StringSplitVectorLength(string,length)
	let l:length=a:length+1
	let l:patt='\%' . l:length . 'v'
	let l:spvec=split(a:string,l:patt)
	return l:spvec
endfunction
""echo genstr#StringSplitVectorLength('1234567890abcdefghijklmn',7)

"GENERATE STRING VECTOR WITH SPAN SEQUENCE AND FIXED ATOM LENGTH:"
function! genstr#StringVectorSpan(charspace,vlength,alength)
	""vlength - vector length
	""alength - atom length
	let l:lenstr=a:vlength*a:alength
	let l:spanstrword=genstr#StringSpan(a:charspace,l:lenstr)
	exe 'let l:lengths=[' . repeat(a:alength . ',' ,a:vlength-1) . a:alength . ']'
	let l:outblock=genstr#StringSplitAtomLengths(l:spanstrword,l:lengths)
	return l:outblock
endfunction
"" Test: genstr#StringVectorSpan
""echo genstr#StringVectorSpan(g:genstr#CharspacesList.czech,91,60)
""echo genstr#StringVectorSpan('abcd efgh',60,60)
""echo genstr#StringVectorSpan(g:genstr#CharspacesList.czech,2,50)

""GENERATE STRING VECTOR WITH RANDOM SEQUENCE AND FIXED ATOM LENGTH:"
function! genstr#StringVectorRand(charspace,vlength,alength)
	let l:lenstr=a:vlength*a:alength
	let l:spanstrword=genstr#StringRand(a:charspace,l:lenstr)
	exe 'let l:lengths=[' . repeat(a:alength . ',' ,a:vlength-1) . a:alength . ']'
	let l:outblock=genstr#StringSplitAtomLengths(l:spanstrword,l:lengths)
	return l:outblock
endfunction
"" Test: genstr#StringVectorRand
""echo genstr#StringVectorRand(g:genstr#CharspacesList.czech,10,10)

""GENERATE STRING VECTOR WITH SPAN SEQUENCE AND RANDOM ATOM LENGTH:"
function! genstr#StringVectorSpanLRand(charspace,vlength,shortest,longest)
	let l:lengths=genstr#NumVecRand(a:shortest,a:longest,a:vlength)
	let l:strvec=[]
	for l:i in l:lengths
		let l:strspan=genstr#StringSpan(a:charspace,l:i)
		call add(l:strvec,l:strspan)
	endfor
	return l:strvec
endfunction
""echo genstr#StringVectorSpanLRand(g:genstr#CharspacesList.czech,10,60,60)
""echo genstr#StringVectorSpanLRand(g:genstr#CharspacesList.aZ10,10,60,60)
"" let vars=genstr#StringVectorSpanLRand(g:genstr#CharspacesList.czech,100,1,1)
""echo vars


""GENERATE STRING VECTOR WITH RANDOM SEQUNECE AND RANDOM ATOM LENGTH:
function! genstr#StringVectorRandLenghtRand(charspace,vlength,shortest,longest)
	let l:lengths=genstr#NumVecRand(a:shortest,a:longest,a:vlength)
	let l:strvec=[]
	let l:strlen=array#ListSum(l:lengths)	
	let l:randstr=genstr#StringRand(a:charspace,l:strlen)
	let l:outblock=genstr#StringSplitAtomLengths(l:randstr,l:lengths)
	return l:outblock
endfunction
""echo genstr#StringVectorRandLenghtRand(g:genstr#CharspacesList.czech,100,1,50)
