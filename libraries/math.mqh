double dprec = 0.00000001;

int di(double dval)
{
   return((int)MathRound(dval));
}

bool q(double val1, double val2)
{
   if (val1 > val2-dprec && val1 < val2+dprec) return(true);
   else return(false);
}

bool lq(double val1, double val2)
{
   if (val1 > val2-dprec) return(true);
   else return(false);
}

bool sq(double val1, double val2)
{
   if (val1 < val2+dprec) return(true);
   else return(false);
}

bool l(double val1, double val2)
{
   if (val1 > val2+dprec) return(true);
   else return(false);
}

bool s(double val1, double val2)
{
   if (val1 < val2-dprec) return(true);
   else return(false);
}

double div(double val1, double val2, string function)
{
   if (val2 != 0) return(val1/val2);
   else {
      Print("Zero Divide in ",function);
      return(EMPTY_VALUE);
   }
}
