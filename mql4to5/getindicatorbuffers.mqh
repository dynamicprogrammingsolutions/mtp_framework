//+------------------------------------------------------------------------------+
//|                                                      GetIndicatorBuffers.mqh |
//|                                                             Copyright DC2008 |
//|                                                          http://www.mql5.com |
//+------------------------------------------------------------------------------+
#property copyright "DC2008"
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------------------+
//| �������� � ������ �������� ���������� � ������ ������� ����������            |
//+------------------------------------------------------------------------------+
bool CopyBufferAsSeries(
                        int handle,      // handle ����������
                        int bufer,       // ����� ������ ����������
                        int start,       // ������ ������
                        int number,      // ������� ��������
                        bool asSeries,   // ������� ���������� �������
                        double &M[]      // ������, ���� ����� ����������� ������
                        )
  {
//--- ���������� ������� M �������� ���������� ����������
   if(CopyBuffer(handle,bufer,start,number,M)<=0) return(false);
//--- ����� ������� ���������� ������� M
//--- ���� asSeries=true, �� ������� ���������� ������� M ��� � ���������
//--- ���� asSeries=false, �� ������� ���������� ������� M �� ���������
   ArraySetAsSeries(M,asSeries);
//---
   return(true);
  }
//+------------------------------------------------------------------------------+
//| �������� � ������� ������� ���������� ADX � ������ ����������                |
//+------------------------------------------------------------------------------+
bool GetADXBuffers(int ADX_handle,
                   int start,
                   int number,
                   double &Main[],
                   double &PlusDI[],
                   double &MinusDI[],
                   bool asSeries=true  // ���������� ��� � ���������
                   )
  {
//--- ���������� ������� Main �������� ���������� MAIN_LINE
   if(!CopyBufferAsSeries(ADX_handle,0,start,number,asSeries,Main)) return(false);
//--- ���������� ������� PlusDI �������� ���������� PLUSDI_LINE
   if(!CopyBufferAsSeries(ADX_handle,1,start,number,asSeries,PlusDI)) return(false);
//--- ���������� ������� MinusDI �������� ���������� MINUSDI_LINE
   if(!CopyBufferAsSeries(ADX_handle,2,start,number,asSeries,MinusDI)) return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------------------+
//| �������� � ������� ������� ���������� ADXWilder � ������ ����������          |
//+------------------------------------------------------------------------------+
bool GetADXWilderBuffers(int ADXWilder_handle,
                         int start,
                         int number,
                         double &Main[],
                         double &PlusDI[],
                         double &MinusDI[],
                         bool asSeries=true  // ���������� ��� � ���������
                         )
  {
//--- ���������� ������� Main �������� ���������� MAIN_LINE
   if(!CopyBufferAsSeries(ADXWilder_handle,0,start,number,asSeries,Main)) return(false);
//--- ���������� ������� PlusDI �������� ���������� PLUSDI_LINE
   if(!CopyBufferAsSeries(ADXWilder_handle,1,start,number,asSeries,PlusDI)) return(false);
//--- ���������� ������� MinusDI �������� ���������� MINUSDI_LINE
   if(!CopyBufferAsSeries(ADXWilder_handle,2,start,number,asSeries,MinusDI)) return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------------------+
//| �������� � ������� ������� ���������� ��������� � ������ ����������          |
//+------------------------------------------------------------------------------+
bool GetAlligatorBuffers(int Alligator_handle,
                         int start,
                         int number,
                         double &Jaws[],
                         double &Teeth[],
                         double &Lips[],
                         bool asSeries=true  // ���������� ��� � ���������
                         )
  {
//--- ���������� ������� Jaws �������� ���������� GATORJAW_LINE
   if(!CopyBufferAsSeries(Alligator_handle,0,start,number,asSeries,Jaws)) return(false);
//--- ���������� ������� Teeth �������� ���������� GATORTEETH_LINE
   if(!CopyBufferAsSeries(Alligator_handle,1,start,number,asSeries,Teeth)) return(false);
//--- ���������� ������� Lips �������� ���������� GATORLIPS_LINE
   if(!CopyBufferAsSeries(Alligator_handle,2,start,number,asSeries,Lips)) return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------------------+
//| �������� � ������� ������� ���������� Bands � ������ ����������              |
//+------------------------------------------------------------------------------+
bool GetBandsBuffers(int Bands_handle,
                     int start,
                     int number,
                     double &Base[],
                     double &Upper[],
                     double &Lower[],
                     bool asSeries=true  // ���������� ��� � ���������
                     )
  {
//--- ���������� ������� Base �������� ���������� BASE_LINE
   if(!CopyBufferAsSeries(Bands_handle,0,start,number,asSeries,Base)) return(false);
//--- ���������� ������� Upper �������� ���������� UPPER_BAND
   if(!CopyBufferAsSeries(Bands_handle,1,start,number,asSeries,Upper)) return(false);
//--- ���������� ������� Lower �������� ���������� LOWER_BAND
   if(!CopyBufferAsSeries(Bands_handle,2,start,number,asSeries,Lower)) return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------------------+
//| �������� � ������� ������� ���������� Envelopes � ������ ����������          |
//+------------------------------------------------------------------------------+
bool GetEnvelopesBuffers(int Envelopes_handle,
                         int start,
                         int number,
                         double &Upper[],
                         double &Lower[],
                         bool asSeries=true       // ���������� ��� � ���������
                         )
  {
//--- ���������� ������� Upper �������� ���������� UPPER_LINE
   if(!CopyBufferAsSeries(Envelopes_handle,0,start,number,asSeries,Upper)) return(false);
//--- ���������� ������� Lower �������� ���������� LOWER_LINE
   if(!CopyBufferAsSeries(Envelopes_handle,1,start,number,asSeries,Lower)) return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------------------+
//| �������� � ������� ������� ���������� Fractals � ������ ����������           |
//+------------------------------------------------------------------------------+
bool GetFractalsBuffers(int Fractals_handle,
                        int start,
                        int number,
                        double &Upper[],
                        double &Lower[],
                        bool asSeries=true       // ���������� ��� � ���������
                        )
  {
//--- ���������� ������� Upper �������� ���������� UPPER_LINE
   if(!CopyBufferAsSeries(Fractals_handle,0,start,number,asSeries,Upper)) return(false);
//--- ���������� ������� Lower �������� ���������� LOWER_LINE
   if(!CopyBufferAsSeries(Fractals_handle,1,start,number,asSeries,Lower)) return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------------------+
//| �������� � ������� ������� ���������� Gator � ������ ����������              |
//+------------------------------------------------------------------------------+
bool GetGatorBuffers(int Gator_handle,
                     int start,
                     int number,
                     double &Upper[],
                     double &Lower[],
                     bool asSeries=true       // ���������� ��� � ���������
                     )
  {
//--- ���������� ������� Upper �������� ���������� UPPER_LINE
   if(!CopyBufferAsSeries(Gator_handle,0,start,number,asSeries,Upper)) return(false);
//--- ���������� ������� Lower �������� ���������� LOWER_LINE
   if(!CopyBufferAsSeries(Gator_handle,1,start,number,asSeries,Lower)) return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------------------+
//| �������� � ������� ������� ���������� Ichimoku � ������ ����������           |
//+------------------------------------------------------------------------------+
bool GetIchimokuBuffers(int Ichimoku_handle,
                        int start,
                        int number,
                        double &Tenkansen[],
                        double &Kijunsen[],
                        double &SenkouspanA[],
                        double &SenkouspanB[],
                        double &Chinkouspan[],
                        bool asSeries=true       // ���������� ��� � ���������
                        )
  {
//--- ���������� ������� Tenkansen �������� ���������� TENKANSEN_LINE
   if(!CopyBufferAsSeries(Ichimoku_handle,0,start,number,asSeries,Tenkansen)) return(false);
//--- ���������� ������� Kijunsen �������� ���������� KIJUNSEN_LINE
   if(!CopyBufferAsSeries(Ichimoku_handle,1,start,number,asSeries,Kijunsen)) return(false);
//--- ���������� ������� SenkouspanA �������� ���������� SENKOUSPANA_LINE
   if(!CopyBufferAsSeries(Ichimoku_handle,2,start,number,asSeries,SenkouspanA)) return(false);
//--- ���������� ������� SenkouspanB �������� ���������� SENKOUSPANB_LINE
   if(!CopyBufferAsSeries(Ichimoku_handle,3,start,number,asSeries,SenkouspanB)) return(false);
//--- ���������� ������� Chinkouspan �������� ���������� CHINKOUSPAN_LINE
   if(!CopyBufferAsSeries(Ichimoku_handle,4,start,number,asSeries,Chinkouspan)) return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------------------+
//| �������� � ������� ������� ���������� MACD � ������ ����������               |
//+------------------------------------------------------------------------------+
bool GetMACDBuffers(int MACD_handle,
                    int start,
                    int number,
                    double &Main[],
                    double &Signal[],
                    bool asSeries=true       // ���������� ��� � ���������
                    )
  {
//--- ���������� ������� Main �������� ���������� MAIN_LINE
   if(!CopyBufferAsSeries(MACD_handle,0,start,number,asSeries,Main)) return(false);
//--- ���������� ������� Signal �������� ���������� SIGNAL_LINE
   if(!CopyBufferAsSeries(MACD_handle,1,start,number,asSeries,Signal)) return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------------------+
//| �������� � ������� ������� ���������� RVI � ������ ����������                |
//+------------------------------------------------------------------------------+
bool GetRVIBuffers(int RVI_handle,
                   int start,
                   int number,
                   double &Main[],
                   double &Signal[],
                   bool asSeries=true       // ���������� ��� � ���������
                   )
  {
//--- ���������� ������� Main �������� ���������� MAIN_LINE
   if(!CopyBufferAsSeries(RVI_handle,0,start,number,asSeries,Main)) return(false);
//--- ���������� ������� Signal �������� ���������� SIGNAL_LINE
   if(!CopyBufferAsSeries(RVI_handle,1,start,number,asSeries,Signal)) return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------------------+
//| �������� � ������� ������� ���������� Stochastic � ������ ����������         |
//+------------------------------------------------------------------------------+
bool GetStochasticBuffers(int Stochastic_handle,
                          int start,
                          int number,
                          double &Main[],
                          double &Signal[],
                          bool asSeries=true       // ���������� ��� � ���������
                          )
  {
//--- ���������� ������� Main �������� ���������� MAIN_LINE
   if(!CopyBufferAsSeries(Stochastic_handle,0,start,number,asSeries,Main)) return(false);
//--- ���������� ������� Signal �������� ���������� SIGNAL_LINE
   if(!CopyBufferAsSeries(Stochastic_handle,1,start,number,asSeries,Signal)) return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------------------+
