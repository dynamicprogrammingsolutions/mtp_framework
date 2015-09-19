//+------------------------------------------------------------------+
//|                                              objectfunctions.mq4 |
//|                                            Zoltan Laszlo Ferenci |
//|                              http://www.metatraderprogrammer.com |
//+------------------------------------------------------------------+
#property copyright "Zoltan Laszlo Ferenci"
#property link      "http://www.metatraderprogrammer.com"

#include "..\mql4to5\renamed_functions.mqh"
#include "..\mql4to5\objects.mqh"

string recent_objname;
int window_idx = 0;
bool obj_force_color = false;

int delobj_retry = 20;
int delobj_wait = 500;

bool hline_put(string name, double price, color cl, int ticket = -1, int width = -1)
{
   if (ticket != -1)
      name = ordobjname(ticket,name);
   recent_objname = name;
   if (ObjectFind(0,name) == -1)
   {
      ObjectCreate(0,name,OBJ_HLINE,window_idx,0,price);
      ObjectSet(name,OBJPROP_COLOR,cl);
      if (width >= 0) ObjectSet(name,OBJPROP_WIDTH,width);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,1);
      return(true);
   }
   else
   {
      ObjectSet(name,OBJPROP_PRICE1,price);
      if (obj_force_color) ObjectSet(name,OBJPROP_COLOR,cl);
      return(false);
   }
}

bool vline_put(string name, datetime time, color cl, int ticket = -1, int width = -1)
{
   if (ticket != -1)
      name = ordobjname(ticket,name);
   recent_objname = name;
   if (ObjectFind(0,name) == -1)
   {
      ObjectCreate(0,name,OBJ_VLINE,window_idx,time,0);
      ObjectSet(name,OBJPROP_COLOR,cl);
      if (width >= 0) ObjectSet(name,OBJPROP_WIDTH,width);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,1);
      return(true);
   }
   else
   {
      ObjectSet(name,OBJPROP_TIME1,time);
      if (obj_force_color) ObjectSet(name,OBJPROP_COLOR,cl);
      return(false);
   }
}


void obj_put(string name, ENUM_OBJECT type, datetime time1, double price1, datetime time2=0, double price2=0, datetime time3=0, double price3=0, int ticket = -1, color cl = 0)
{
   if (ticket != -1)
      name = ordobjname(ticket,name);
   recent_objname = name;
   ObjectDelete(name);
   ObjectCreate(name,type,0,time1,price1,time2,price2,time3,price3);
   if (cl != 0) {
      ObjectSet(name,OBJPROP_COLOR,cl);
   }
}

bool line_beingdragged(string name, int ticket = -1)
{
   return(hline_beingdragged(name, ticket));
}

bool hline_beingdragged(string name, int ticket = -1)
{
   if (name == "") {
      Print("hline_beingdragged: empty name");
      return(false);
   }
   if (ticket != -1)
      name = ordobjname(ticket,name);
   double price = ObjectGet(name,OBJPROP_PRICE);
   double priceto = MathRound((price+_Point)/_Point)*_Point;
   ObjectSet(name,OBJPROP_PRICE,priceto);
   double price1 = ObjectGet(name,OBJPROP_PRICE);
   if (price1 == priceto) {
      ObjectSet(name,OBJPROP_PRICE1,price);
      return(false);
   } else {
      return(true);
   }
}

void arrow_put(string name, datetime time1, double price1, int arrowcode, color cl, int ticket = -1)
{
   if (ticket != -1)
      name = ordobjname(ticket,name);
   obj_put(name,OBJ_ARROW,time1,price1,0,0,0,0,-1,cl);
   ObjectSet(name,OBJPROP_ARROWCODE,arrowcode);
}

bool objfind(string name,int ticket = -1)
{
   if (ticket != -1)
      name = ordobjname(ticket,name);
   if (ObjectFind(name) >= 0) return(true);
   else return(false);
}

void obj_set(int prop, double value)
{
   ObjectSet(recent_objname,prop,value);
}

double hline_get(string name, int ticket = -1)
{
   if (ticket != -1)
      name = ordobjname(ticket,name);
   if (ObjectFind(name) == -1)
      return(-1);
   else
      return(ObjectGet(name,OBJPROP_PRICE));
}

double line_get(string name, int ticket = -1, int bar = 0)
{
   if (ticket != -1)
      name = ordobjname(ticket,name);
   if (ObjectFind(name) == -1) return(-1);

   int type = ObjectType(name);

   if (type == OBJ_HLINE) {
      return(ObjectGet(name,OBJPROP_PRICE));
   }
   if (type == OBJ_TREND)
    return(ObjectGetValueByShift(name,bar));

   return(-1);
}

void change_hline_to_trendline(string name, int bar_start = 5, int bar_end = 0, int ticket = -1)
{
   if (ticket != -1)
      name = ordobjname(ticket,name);
   if (ObjectFind(name) == -1) return;
   double price = line_get(name);
   color cl = (color)ObjectGet(name,OBJPROP_COLOR);
   datetime time1 = iTime(Symbol(),0,bar_start);
   datetime time2 = iTime(Symbol(),0,bar_end);
   objdel(name);
   obj_put(name, OBJ_TREND, time1, price, time2, price, 0, 0, -1, cl);
}

void objdel(string name, int ticket = -1)
{
   if (ticket != -1)
      name = ordobjname(ticket,name);
   for (int i = 0; i <= delobj_retry; i++) {
      ObjectDelete(name);
      if (!objfind(name)) break;
      else Sleep(delobj_wait);
   }     
}

string ordobjname(int ticket, string name)
{
   return(DoubleToStr(ticket,0)+name);
}

void obj_changedesc(string name, string text, int ticket = -1)
{
   if (ticket != -1)
      name = ordobjname(ticket,name);
   ObjectSetText(name,text,0);
}

void obj_storetext(string name, string text, int ticket = -1)
{
   if (ticket != -1)
      name = ordobjname(ticket,name);
   hline_put(name,0,CLR_NONE);
   ObjectSetText(name,text,0);
}

void obj_storeint(string name, int num, int ticket = -1)
{
   obj_storetext(name,DoubleToStr(num,0),ticket);
}

void obj_storebool(string name, bool num, int ticket = -1)
{
   obj_storetext(name,DoubleToStr(num,0),ticket);
}

void obj_storedouble(string name, double num, int ticket = -1)
{
   string strcon;
   StringConcatenate(strcon,num,"");
   obj_storetext(name,strcon,ticket);
}

void obj_storetime(string name, datetime num, int ticket = -1)
{
   obj_storetext(name,DoubleToStr(num,0),ticket);
}

string obj_getdesc(string name, int ticket = -1)
{
   if (ticket != -1)
      name = ordobjname(ticket,name);
   return(ObjectDescription(name));
}

int obj_getdesc_int(string name, int ticket = -1)
{
   string str = obj_getdesc(name,ticket);
   if (str == "")
      return((int)EMPTY_VALUE);
   else
      return((int)MathRound(StrToDouble(str)));
}

/*bool obj_getdesc_bool(string name, int ticket = -1)
{
   string str = obj_getdesc(name,ticket);
   if (str == "")
      return((bool)EMPTY_VALUE);
   else
      return(MathRound(StrToDouble(str)));
}*/

double obj_getdesc_double(string name, int ticket = -1)
{
   string str = obj_getdesc(name,ticket);
   if (str == "")
      return(EMPTY_VALUE);
   else
      return(StrToDouble(str));
}

void obj_loaddouble(string name, double& var, int ticket = -1)
{
   string str = obj_getdesc(name,ticket);
   if (str != "")
      var = StrToDouble(str);
   return;
}

void obj_loadint(string name, int& var, int ticket = -1)
{
   string str = obj_getdesc(name,ticket);
   if (str != "")
      var = (int)MathRound(StrToDouble(str));
   return;
}

void obj_loadtime(string name, datetime& var, int ticket = -1)
{
   string str = obj_getdesc(name,ticket);
   if (str != "")
      var = (datetime)MathRound(StrToDouble(str));
   return;
}

void obj_loadbool(string name, bool& var, int ticket = -1)
{
   string str = obj_getdesc(name,ticket);
   if (str != "")
      var = MathRound(StrToDouble(str));
   return;
}