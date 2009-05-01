#import "Three20/TTDateField.h"
#import "Three20/TTStyleSheet.h"
#import "Three20/TTGlobal.h"

@implementation TTDateField

@synthesize dateFieldMode = _dateFieldMode, formatter = _formatter;
@synthesize pickerView = _pickerView, valueLabel = _valueLabel, leftView = _leftView;

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _formatter = [NSDateFormatter new];
    [_formatter setDateStyle:NSDateFormatterMediumStyle];
    
    _helperField = [[TTPickerTextField alloc] initWithFrame:frame];
    [self addSubview:_helperField];
    _helperField.delegate = self;
    _helperField.leftViewMode = UITextFieldViewModeAlways;
    _helperField.font = TTSTYLEVAR(messageFont);
    _helperField.backgroundColor = TTSTYLEVAR(backgroundColor);
    
    self.valueLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    self.valueLabel.backgroundColor = _helperField.backgroundColor;
    self.valueLabel.font = _helperField.font;
    self.valueLabel.opaque = YES;
    self.valueLabel.hidden = YES;
    self.valueLabel.userInteractionEnabled = YES;
    [_helperField addSubview:self.valueLabel];
    
    self.date = [NSDate date];
  }
  return self;
}

- (void)dealloc {
  [_formatter release], _formatter = nil;
  [_pickerView release], _pickerView = nil;
  [_valueLabel release], _valueLabel = nil;
  [_helperField release], _helperField = nil;
  [_leftView release], _leftView = nil;
  [super dealloc];
}

- (UIView *)keyboardView {
  for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
    for (UIView *view in [window subviews]) {
      NSString *viewClassName = NSStringFromClass([view class]);
      if ([viewClassName isEqual:@"UIKeyboard"]) {
        return view;
      }
    }
  }
  return nil;
}

- (UIDatePicker *)pickerView {
  if (_pickerView == nil) {
    _pickerView = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    _pickerView.hidden = YES;
    [_pickerView addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
  }
  return _pickerView;
}

- (NSDate *)date {
  return self.pickerView.date;
}

- (void)setDate:(NSDate *)date {
  if (date) {
    self.pickerView.date = date;
    self.valueLabel.text = [self.formatter stringFromDate:date];
    _helperField.text = [self.formatter stringFromDate:date];
  }
}

- (void)dateChanged {
  self.valueLabel.text = [self.formatter stringFromDate:self.date];
  _helperField.text = [self.formatter stringFromDate:self.date];
}

- (void)setDateFieldMode:(TTDateFieldMode)dateFieldMode {
  _dateFieldMode = dateFieldMode;
  switch (dateFieldMode) {
    case TTDateFieldModeDate:
      [self.formatter setDateStyle:NSDateFormatterLongStyle];
      [self.formatter setTimeStyle:NSDateFormatterNoStyle];
      self.pickerView.datePickerMode = UIDatePickerModeDate;
      break;
    case TTDateFieldModeTime:
      [self.formatter setDateStyle:NSDateFormatterNoStyle];
      [self.formatter setTimeStyle:NSDateFormatterMediumStyle];
      self.pickerView.datePickerMode = UIDatePickerModeTime;
      break;
    case TTDateFieldModeDateAndTime:
      [self.formatter setDateStyle:NSDateFormatterLongStyle];
      [self.formatter setTimeStyle:NSDateFormatterMediumStyle];
      self.pickerView.datePickerMode = UIDatePickerModeDateAndTime;
      break;
  }
  [self dateChanged];
}

- (void)setLeftView:(UIView *)leftView {
  if (leftView != _helperField.leftView) {
    _helperField.leftView = leftView;
  }
}

- (void)setValueLabel:(UILabel *)valueLabel {
  if (valueLabel != _valueLabel) {
    [_valueLabel removeFromSuperview];
    [self addSubview:valueLabel];
    _valueLabel = valueLabel;
  }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  UIView *keyboardView = [self keyboardView];
  self.pickerView.hidden = NO;
  [keyboardView addSubview:self.pickerView];
  
  self.valueLabel.hidden = NO;
  self.valueLabel.font = _helperField.font;
  [_helperField bringSubviewToFront:self.valueLabel];
  [self setNeedsLayout];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  self.pickerView.hidden = YES;
  [self.pickerView removeFromSuperview];
  
  self.valueLabel.hidden = YES;
}

- (CGSize)sizeThatFits:(CGSize)size {
  return [_helperField sizeThatFits:size];
}

- (void)layoutSubviews {  
  _helperField.frame = self.bounds;
  self.valueLabel.frame = [_helperField editingRectForBounds:_helperField.bounds];
}

@end
