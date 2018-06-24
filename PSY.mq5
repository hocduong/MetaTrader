//+------------------------------------------------------------------+
//|                                                          PSY.mq5 |
//|                                                 Gogojungle Corp. |
//|                                        https://gogojungle.co.jp/ |
//+------------------------------------------------------------------+
#property copyright "Gogojungle Corp."
#property link      "https://gogojungle.co.jp/"
#property version   "1.00"
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  DodgerBlue
//--- input parameters
input int InpPeriodRSI=12; // Period
//--- indicator buffers
double    ExtRSIBuffer[];

//--- global variable
int       ExtPeriodRSI;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- check for input

   if(InpPeriodRSI<1)
     {
      ExtPeriodRSI=12;
      Print("Incorrect value for input variable InpPeriodPSY =",InpPeriodRSI,
            "Indicator will use value =",ExtPeriodRSI,"for calculations.");
     }
   else ExtPeriodRSI=InpPeriodRSI;
   
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtRSIBuffer,INDICATOR_DATA);
//--- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"PSY("+string(ExtPeriodRSI)+")");
//--- initialization done
  }
//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   int    i;
   double diff;
   double SumP=0.0;
   
//--- check for rates count
   if(rates_total<=ExtPeriodRSI)
      return(0);
      
//--- preliminary calculations
//--- bars handled on a previous calculate
   int pos=prev_calculated-1;
   if(pos<=ExtPeriodRSI)
     {
      //--- first RSIPeriod values of the indicator are not calculated
      ExtRSIBuffer[0]=0.0;
      
      for(i=1;i<=ExtPeriodRSI;i++)
        {
         ExtRSIBuffer[i]=0.0;
         diff=price[i]-price[i-1];
         SumP+=(diff>0?1:0);
        }
      
       ExtRSIBuffer[ExtPeriodRSI]= SumP *100 / ExtPeriodRSI;

      //--- prepare the position value for main calculation
      pos=ExtPeriodRSI+1;
     }
     
     
//--- the main loop of calculations
   for(i=pos;i<rates_total && !IsStopped();i++)
     {
     
      SumP = ExtRSIBuffer[i -1] * ExtPeriodRSI / 100;
      
      // calculate curent position. 
      diff=price[i]-price[i-1];
      SumP+=(diff>0?1:0);
      
      // remove last start position.
      diff=price[i - ExtPeriodRSI]-price[i- ExtPeriodRSI -1];
      SumP-= (diff>0?1:0);
      
      ExtRSIBuffer[i]= SumP *100 / ExtPeriodRSI;

     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+