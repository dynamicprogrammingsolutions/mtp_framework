//

class CChartComment : public CServiceProvider
{
public:
   TraitAppAccess
   
   virtual void OnTick()
   {
      if (comments_enabled) {
         if (comment_formatting) writecomment();
         else writecomment_noformat();
         if (printcomment) printcomment();
         delcomment();
      } else {
         delcomment();
      }
   }
   
   virtual void OnInit()
   {

#ifdef COMMENT_ENABLE_PARAM
      comments_enabled = _comments_enabled;
#endif

#ifdef COMMENT_FORMAT

      comment_formatting = _comment_formatting;
      objname_comment = _objname_comment;
      comment_corner = _comment_corner;
      
#ifdef COMMENT_AUTO_REVERSE
      if (comment_corner == CORNER_LEFT_LOWER || comment_corner == CORNER_RIGHT_LOWER)
         comment_reverse_lines = true;
      else
         comment_reverse_lines = false;
#else      
      comment_reverse_lines = _comment_reverse_lines;
#endif

      comment_fontsize = _comment_fontsize;
      comment_font = _comment_font;
      comment_color = _comment_color;
      comment_x = _comment_x;
      comment_y = _comment_y;
      comment_lineheight = _comment_lineheight;
      comment_window = _comment_window;
      
#endif

      if (IsTesting() && !IsVisualMode() && !printcomment) {    
         comments_enabled = false;
      }    
   }
};