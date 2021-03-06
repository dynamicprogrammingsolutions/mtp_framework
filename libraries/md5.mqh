string MD5(string str)
{
    int len = StringLen(str);
    int index = len % 64; //mod 64
    int count = (len - index) / 64;
    
    int a = 0x67452301, b = 0xEFCDAB89, c = 0x98BADCFE, d = 0x10325476;
    int buff[16], last[16], i, k, last_char[4], last_index, offset;
    string item;
    for (i = 0; i < count; i++)
    {
        item = StringSubstr(str, i * 64, 64);
        StringToIntegerArray(buff, item);
        MD5Transform(a, b , c, d, buff);
    }
    ArrayInitialize(last, 0);
    ArrayInitialize(last_char, 0);
    last_index = 0;
    if (index > 0) {
      int last_num = index % 4;
      count = index - last_num;
      if (count > 0) {
         item = StringSubstr(str, i * 64, count);
         last_index = StringToIntegerArray(last, item);
      }
      for (k = 0; k < last_num; k++)
      {
          last_char[k] = StringGetChar(str, i * 64 + count + k); 
      }
    }
    last_char[k] = 0x80;
    last[last_index] = CharToInteger(last_char);
    if (index >= 56) {
        MD5Transform(a, b , c, d, last);
        ArrayInitialize(last, 0);
    }
    last[14] =  len << 3;
    last[15] =  ((len >> 1) & 0x7fffffff) >> 28;
    MD5Transform(a, b , c, d, last);
    return (StringConcatenate(IntegerToString(a) , IntegerToString(b) , IntegerToString(c) ,  IntegerToString(d)));
}

int F(int x, int y, int z) 
{ 
    return ((x & y) | ((~x) & z)); 
}

int G(int x, int y, int z) 
{ 
    return ((x & z) | (y & (~z))); 
}

int H(int x, int y, int z) 
{ 
    return ((x ^ y ^ z));
}

int I(int x, int y, int z) 
{ 
    return ((y ^ (x | (~z))));
}

int AddUnsigned(int a, int b)
{
    int c = a + b;
    return (c);
}

int FF(int a, int b, int c, int d, int x, int s, int ac) 
{
	a = AddUnsigned(a, AddUnsigned(AddUnsigned(F(b, c, d), x), ac));
	return (AddUnsigned(RotateLeft(a, s), b));
}

int GG(int a, int b, int c, int d, int x, int s, int ac) 
{
	a = AddUnsigned(a, AddUnsigned(AddUnsigned(G(b, c, d), x), ac));
	return (AddUnsigned(RotateLeft(a, s), b));
}

int HH(int a, int b, int c, int d, int x, int s, int ac) 
{
	a = AddUnsigned(a, AddUnsigned(AddUnsigned(H(b, c, d), x), ac));
	return (AddUnsigned(RotateLeft(a, s), b));
}

int II(int a, int b, int c, int d, int x, int s, int ac) 
{
	a = AddUnsigned(a, AddUnsigned(AddUnsigned(I(b, c, d), x), ac));
	return (AddUnsigned(RotateLeft(a, s), b));
}

int RotateLeft(int lValue, int iShiftBits) 
{ 
    if (iShiftBits == 32) return (lValue);
    int result = (lValue << iShiftBits) | (((lValue >> 1) & 0x7fffffff) >> (31 - iShiftBits));
    return (result);
}

/*
* assume: len % 4 == 0; 
*/
int StringToIntegerArray(int &output[], string input_)
{
   int len;
   int i, j;
   len = StringLen(input_);
   if (len % 4 !=0) len = len - len % 4;
   int size = ArraySize(output);
   if (size < len/4) {
       ArrayResize(output, len/4);
   }
   for (i = 0, j = 0; j < len; i++, j += 4) 
   {
       output[i] = (StringGetChar(input_, j)) | ((StringGetChar(input_, j+1)) << 8) 
                | ((StringGetChar(input_, j+2)) << 16) | ((StringGetChar(input_, j+3)) << 24);
   }
   return(len/4);
}

string IntegerToString(int integer_number)
{
   string hex_string="", hex_item;
   int output[4];
   output[0] = integer_number & 0xff;
   for (int k = 1; k < 4; k++) 
   {
       output[k] = (((integer_number >> 1) & 0x7fffffff) >> (k*8 -1)) & 0xff;
   }
   for (int i = 0; i < 4; i++)
   {
       hex_item = Dec2Hex(output[i]);
       hex_string = StringConcatenate(hex_string, hex_item);
   }
   return(hex_string);
}

/**
*assume num is little than 256
*/

string Dec2Hex(int num)
{
    int modnum;
    string hex;
    for (int i =0; i < 2; i++)
    {
        modnum = num % 16;
        num = (num - modnum) / 16;
        hex = StringConcatenate(IntToHexString(modnum), hex);
    }
    return (hex);
}

string IntToHexString(int a)
{
    string hex = "0";
    int ascii;
    if (a < 10) {
       ascii = '0' + a;
    } else {
       ascii = 'a' + a - 10;
    }
    return (StringSetChar(hex, 0, ascii));
}

int CharToInteger(int &a[])
{
    return ((a[0]) | (a[1] << 8) | (a[2] << 16) | (a[3] << 24));
}

/*
* assume: ArraySize(x) == 16
*/
void MD5Transform(int &a, int &b, int &c, int &d, int &x[])
{
   int AA, BB, CC, DD;
	int S11=7, S12=12, S13=17, S14=22;
	int S21=5, S22=9 , S23=14, S24=20;
	int S31=4, S32=11, S33=16, S34=23;
	int S41=6, S42=10, S43=15, S44=21;

   AA=a; BB=b; CC=c; DD=d;
   a=FF(a,b,c,d,x[0], S11,0xD76AA478);
   d=FF(d,a,b,c,x[1], S12,0xE8C7B756);
   c=FF(c,d,a,b,x[2], S13,0x242070DB);
   b=FF(b,c,d,a,x[3], S14,0xC1BDCEEE);
   a=FF(a,b,c,d,x[4], S11,0xF57C0FAF);
   d=FF(d,a,b,c,x[5], S12,0x4787C62A);
   c=FF(c,d,a,b,x[6], S13,0xA8304613);
   b=FF(b,c,d,a,x[7], S14,0xFD469501);
   a=FF(a,b,c,d,x[8], S11,0x698098D8);
   d=FF(d,a,b,c,x[9], S12,0x8B44F7AF);
   c=FF(c,d,a,b,x[10],S13,0xFFFF5BB1);
   b=FF(b,c,d,a,x[11],S14,0x895CD7BE);
   a=FF(a,b,c,d,x[12],S11,0x6B901122);
   d=FF(d,a,b,c,x[13],S12,0xFD987193);
   c=FF(c,d,a,b,x[14],S13,0xA679438E);
   b=FF(b,c,d,a,x[15],S14,0x49B40821);
   
   a=GG(a,b,c,d,x[1], S21,0xF61E2562);
   d=GG(d,a,b,c,x[6], S22,0xC040B340);
   c=GG(c,d,a,b,x[11],S23,0x265E5A51);
   b=GG(b,c,d,a,x[0], S24,0xE9B6C7AA);
   a=GG(a,b,c,d,x[5], S21,0xD62F105D);
   d=GG(d,a,b,c,x[10],S22,0x2441453);
   c=GG(c,d,a,b,x[15],S23,0xD8A1E681);
   b=GG(b,c,d,a,x[4], S24,0xE7D3FBC8);
   a=GG(a,b,c,d,x[9], S21,0x21E1CDE6);
   d=GG(d,a,b,c,x[14],S22,0xC33707D6);
   c=GG(c,d,a,b,x[3], S23,0xF4D50D87);
   b=GG(b,c,d,a,x[8], S24,0x455A14ED);
   a=GG(a,b,c,d,x[13],S21,0xA9E3E905);
   d=GG(d,a,b,c,x[2], S22,0xFCEFA3F8);
   c=GG(c,d,a,b,x[7], S23,0x676F02D9);
   b=GG(b,c,d,a,x[12],S24,0x8D2A4C8A);

   a=HH(a,b,c,d,x[5], S31,0xFFFA3942);
   d=HH(d,a,b,c,x[8], S32,0x8771F681);
   c=HH(c,d,a,b,x[11],S33,0x6D9D6122);
   b=HH(b,c,d,a,x[14],S34,0xFDE5380C);
   a=HH(a,b,c,d,x[1], S31,0xA4BEEA44);
   d=HH(d,a,b,c,x[4], S32,0x4BDECFA9);
   c=HH(c,d,a,b,x[7], S33,0xF6BB4B60);
   b=HH(b,c,d,a,x[10],S34,0xBEBFBC70);
   a=HH(a,b,c,d,x[13],S31,0x289B7EC6);
   d=HH(d,a,b,c,x[0], S32,0xEAA127FA);
   c=HH(c,d,a,b,x[3], S33,0xD4EF3085);
   b=HH(b,c,d,a,x[6], S34,0x4881D05);
   a=HH(a,b,c,d,x[9], S31,0xD9D4D039);
   d=HH(d,a,b,c,x[12],S32,0xE6DB99E5);
   c=HH(c,d,a,b,x[15],S33,0x1FA27CF8);
   b=HH(b,c,d,a,x[2], S34,0xC4AC5665);

   a=II(a,b,c,d,x[0], S41,0xF4292244);
   d=II(d,a,b,c,x[7], S42,0x432AFF97);
   c=II(c,d,a,b,x[14],S43,0xAB9423A7);
   b=II(b,c,d,a,x[5], S44,0xFC93A039);
   a=II(a,b,c,d,x[12],S41,0x655B59C3);
   d=II(d,a,b,c,x[3], S42,0x8F0CCC92);
   c=II(c,d,a,b,x[10],S43,0xFFEFF47D);
   b=II(b,c,d,a,x[1], S44,0x85845DD1);
   a=II(a,b,c,d,x[8], S41,0x6FA87E4F);
   d=II(d,a,b,c,x[15],S42,0xFE2CE6E0);
   c=II(c,d,a,b,x[6], S43,0xA3014314);
   b=II(b,c,d,a,x[13],S44,0x4E0811A1);
   a=II(a,b,c,d,x[4], S41,0xF7537E82);
   d=II(d,a,b,c,x[11],S42,0xBD3AF235);
   c=II(c,d,a,b,x[2], S43,0x2AD7D2BB);
   b=II(b,c,d,a,x[9], S44,0xEB86D391);

   a=AddUnsigned(a, AA); b=AddUnsigned(b, BB);
   c=AddUnsigned(c, CC); d=AddUnsigned(d, DD);
}