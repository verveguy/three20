#import <UIKit/UIKit.h>

#import "TTPickerTextField.h"

typedef enum {
  TTDateFieldModeDate,
  TTDateFieldModeTime,
  TTDateFieldModeDateAndTime
} TTDateFieldMode;

@interface TTDateField : UIControl<UITextFieldDelegate> {
  TTDateFieldMode _dateFieldMode;
  NSDateFormatter *_formatter;
  UIDatePicker *_pickerView;
  TTPickerTextField *_helperField;
  UILabel *_valueLabel;
  UIView *_leftView;
}

@property (nonatomic) TTDateFieldMode dateFieldMode;

@property (nonatomic, retain) NSDateFormatter *formatter;
@property (nonatomic, retain) UIDatePicker *pickerView;
@property (nonatomic, retain) UILabel *valueLabel;
@property (nonatomic, retain) UIView *leftView;

@property (nonatomic, retain) NSDate *date;

@end
