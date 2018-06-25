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
input int InpPeriodASY=5; // Period
//--- indicator buffers
double    ExtASYBuffer[];

//--- global variable
int       ExtPeriodASY;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
  
//--- check for input

   if(InpPeriodASY<1)
     {
      ExtPeriodASY=5;
      Print("Incorrect value for input variable InpPeriodASY =",InpPeriodASY,
            "Indicator will use value =",ExtPeriodASY,"for calculations.");
     }
   else ExtPeriodASY=InpPeriodASY;
   
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtASYBuffer,INDICATOR_DATA);
//--- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"ASY("+string(ExtPeriodASY)+")");
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
   if(rates_total<=ExtPeriodASY)
      return(0);
      
//--- preliminary calculations
//--- bars handled on a previous calculate
   int pos=prev_calculated-1;
   if(pos<=ExtPeriodASY)
     {
      //--- first RSIPeriod values of the indicator are not calculated
      ExtASYBuffer[0]=0.0;
      
      for(i=1;i<=ExtPeriodASY;i++)
        {
         ExtASYBuffer[i]=0.0;
         diff=log(price[i])- log(price[i-1]);
         SumP+= diff *100;
        }
      
       ExtASYBuffer[ExtPeriodASY]= SumP / ExtPeriodASY;

      //--- prepare the position value for main calculation
      pos=ExtPeriodASY+1;
     }
     
//--- the main loop of calculations
   for(i=pos;i<rates_total && !IsStopped();i++)
     {
     
      SumP = ExtASYBuffer[i -1] * ExtPeriodASY;
      
      // calculate current position. 
      diff= log(price[i])- log(price[i-1]);
      SumP+= diff*100;
      
      // remove last start position.
      diff= log(price[i - ExtPeriodASY]) - log(price[i- ExtPeriodASY -1]);
      SumP-= diff*100;
      
      ExtASYBuffer[i]= SumP / ExtPeriodASY;

     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+