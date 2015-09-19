//+------------------------------------------------------------------+
//|                                                     comments.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

#include "arrays.mqh"
#include "objectfunctions_MT5.mqh"
#include "..\mql4to5\timeseries.mqh"

string commentstring[];
string lastcommentstring[];

bool comments_enabled = true;
bool comment_formatting = false;
string objname_comment = "comment_textbox";
int comment_corner = 0;
int comment_fontsize = 7;
string comment_font = "Tahoma";
color comment_color = White;
int comment_x = 10;
int comment_y = 15;
int comment_lineheight = 11;
int comment_window = 0;


void addcomment_(int id, const string c1)
{
   if (!comments_enabled) return;
   array_increase_string(commentstring,id+1);
   commentstring[id] = commentstring[id]+c1;
}

void addcomment(const string c1)
{
   if (!comments_enabled) return;
   if (ArraySize(commentstring) == 0) ArrayResize(commentstring,1);
   commentstring[0] = commentstring[0]+c1;
}

void clear0(string& str)
{
   for (int i = 0; i < StringLen(str); i++)
   {
      string chr = StringSubstr(str,i,1);
      if (chr != "0" && chr != "." && chr != "1" && chr != "2" && chr != "3" && chr != "4"
      && chr != "5" && chr != "6" && chr != "7" && chr != "8" && chr != "9" && chr != "-")
         return;
   }
   if (StringFind(str,".",1)>=0)
   {
      while (StringFind(str,"0",StringLen(str)-1)>=0)
      {
         str = StringSubstr(str,0,StringLen(str)-1);
      }
      if (StringFind(str,".",StringLen(str)-1)>=0)
         str = StringSubstr(str,0,StringLen(str)-1);
   }
}

void writecomment_(int id/*, bool comment_formatting, string objname_comment, int comment_corner, int comment_fontsize, string comment_font, color comment_color, int comment_x, int comment_y, int comment_lineheight, int comment_window = 0*/)
{
   if (!comments_enabled) return;
   array_increase_string(commentstring,id+1,"");

   int cnt_line = 0;
   int pos = 0;
   int lineend = 0;
   string currentline = "";
   string name_currentline;
   string substr;
   string _currentline;
   int ypos_currentline;
   color linecolor;
   string linefont;
   int linefontsize;
   color cl;
   int strfind1, strfind2;
   int xshift;
   int yshift;
   int yspaceafter;
   int yextra = 0;
      
   if (comment_formatting) {
      while (pos < StringLen(commentstring[id])) {
         lineend = StringFind(commentstring[id],"\n",pos);
         if (lineend < 0) lineend = StringLen(commentstring[id]);
         if (lineend-pos == 0) currentline = "";
         else currentline = StringSubstr(commentstring[id],pos,lineend-pos);

         pos = lineend+1;
         name_currentline = objname_comment+"_"+DoubleToStr(id,0)+"_"+DoubleToStr(cnt_line,0);
         ypos_currentline = comment_y+comment_lineheight*cnt_line+yextra;
         linecolor = comment_color;
         linefont = comment_font;
         linefontsize = comment_fontsize;
         
         strfind1 = StringFind(currentline,"[cl=",0);
         if (strfind1 >= 0) {
            strfind2 = StringFind(currentline,"]",strfind1);
            substr = StringSubstr(currentline,strfind1+4,strfind2-strfind1-4);
            cl = (color)StrToDouble(substr);
            if (cl > 0) linecolor = cl;
            _currentline = "";
            if (strfind1>0) _currentline = StringSubstr(currentline,0,strfind1);
            _currentline = _currentline+StringSubstr(currentline,strfind2+1);
            currentline = _currentline;
         }
         
         strfind1 = StringFind(currentline,"[font=",0);
         if (strfind1 >= 0) {
            strfind2 = StringFind(currentline,"]",strfind1);
            substr = StringSubstr(currentline,strfind1+6,strfind2-strfind1-6);
            linefont = substr;
            _currentline = "";
            if (strfind1>0) _currentline = StringSubstr(currentline,0,strfind1);
            _currentline = _currentline+StringSubstr(currentline,strfind2+1);
            currentline = _currentline;
         }
         
         strfind1 = StringFind(currentline,"[fontsize=",0);
         if (strfind1 >= 0) {
            strfind2 = StringFind(currentline,"]",strfind1);
            substr = StringSubstr(currentline,strfind1+10,strfind2-strfind1-10);
            linefontsize = (int)StrToDouble(substr);
            _currentline = "";
            if (strfind1>0) _currentline = StringSubstr(currentline,0,strfind1);
            _currentline = _currentline+StringSubstr(currentline,strfind2+1);
            currentline = _currentline;
         }
         

         xshift = 0;
         strfind1 = StringFind(currentline,"[xshift=",0);
         if (strfind1 >= 0) {
            strfind2 = StringFind(currentline,"]",strfind1);
            substr = StringSubstr(currentline,strfind1+8,strfind2-strfind1-8);
            xshift = (int)StrToDouble(substr);
            _currentline = "";
            if (strfind1>0) _currentline = StringSubstr(currentline,0,strfind1);
            _currentline = _currentline+StringSubstr(currentline,strfind2+1);
            currentline = _currentline;
         }
         
         yshift = 0;
         strfind1 = StringFind(currentline,"[yshift=",0);
         if (strfind1 >= 0) {
            strfind2 = StringFind(currentline,"]",strfind1);
            substr = StringSubstr(currentline,strfind1+8,strfind2-strfind1-8);
            yshift = (int)StrToDouble(substr);
            _currentline = "";
            if (strfind1>0) _currentline = StringSubstr(currentline,0,strfind1);
            _currentline = _currentline+StringSubstr(currentline,strfind2+1);
            currentline = _currentline;
         }
         
         yspaceafter = 0;
         strfind1 = StringFind(currentline,"[yspaceafter=",0);
         if (strfind1 >= 0) {
            strfind2 = StringFind(currentline,"]",strfind1);
            substr = StringSubstr(currentline,strfind1+13,strfind2-strfind1-13);
            yspaceafter = (int)StrToDouble(substr);
            _currentline = "";
            if (strfind1>0) _currentline = StringSubstr(currentline,0,strfind1);
            _currentline = _currentline+StringSubstr(currentline,strfind2+1);
            currentline = _currentline;
         }
         yextra += yspaceafter;
         
         ObjectCreate(name_currentline,OBJ_LABEL,comment_window,0,0,0,0);
         ObjectSet(name_currentline,OBJPROP_CORNER,comment_corner);
         ObjectSet(name_currentline,OBJPROP_XDISTANCE,comment_x+xshift);
         ObjectSet(name_currentline,OBJPROP_YDISTANCE,ypos_currentline+yshift);
         if (currentline == "") currentline = " ";
         ObjectSetText(name_currentline,currentline,linefontsize,linefont,linecolor);
         cnt_line++;
      }
      name_currentline = objname_comment+"_"+DoubleToStr(id,0)+"_"+DoubleToStr(cnt_line,0);
      while (ObjectFind(name_currentline) >= 0) {
         ObjectDelete(name_currentline);
         cnt_line++;
         name_currentline = objname_comment+"_"+DoubleToStr(id,0)+"_"+DoubleToStr(cnt_line,0);
      }
      //Comment("");
   } else {
      Comment(commentstring[id]);
      cnt_line = 0;
      name_currentline = objname_comment+DoubleToStr(cnt_line,0);
      while (ObjectFind(name_currentline) >= 0) {
         ObjectDelete(name_currentline);
         cnt_line++;
         name_currentline = objname_comment+DoubleToStr(cnt_line,0);
      }
   }
}

void clearcomment_(int id)
{
   int cnt_line = 0;
   string name_currentline;
   if (comment_formatting) {
      name_currentline = objname_comment+"_"+DoubleToStr(id,0)+"_"+DoubleToStr(cnt_line,0);
      while (ObjectFind(name_currentline) >= 0) {
         ObjectDelete(name_currentline);
         cnt_line++;
         name_currentline = objname_comment+"_"+DoubleToStr(id,0)+"_"+DoubleToStr(cnt_line,0);
      }
   }
}

void clearcomment()
{
   clearcomment_(0);
}

void removecomment()
{
   removecomment_(0);
}

void removecomment_(int id)
{
   int cnt_line = 0;
   string name_currentline = objname_comment+"_"+DoubleToStr(id,0)+"_"+DoubleToStr(cnt_line,0);
   while (ObjectFind(name_currentline) >= 0) {
      ObjectDelete(name_currentline);
      cnt_line++;
      name_currentline = objname_comment+"_"+DoubleToStr(id,0)+"_"+DoubleToStr(cnt_line,0);
   }
}


void writecomment_noformat()
{
   if (!comments_enabled) return;
   Comment(commentstring[0]);
}

void writecomment()
{
   if (!comments_enabled) return;
   writecomment_(0);
}

void printcomment_(int id)
{   
   if (!comments_enabled) return;
   array_increase_string(commentstring,id+1,"");
   array_increase_string(lastcommentstring,id+1,"");
   if (commentstring[id] != lastcommentstring[id]) {
      Print("Comment: ",commentstring[id]);
      lastcommentstring[id] = commentstring[id];
   }
}

void printcomment()
{
   if (!comments_enabled) return;
   printcomment_(0);
}

void delcomment_(int id)
{
   if (!comments_enabled) return;
   commentstring[id] = "";   
}

void delcomment()
{
   if (!comments_enabled) return;
   delcomment_(0);
}
