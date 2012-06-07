//
//  AskerViewController.m
//
//  Created by CS193p Instructor.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "AskerViewController.h"

@interface AskerViewController() <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UITextField *answerTextField;
@end

@implementation AskerViewController

#pragma mark - Properties

@synthesize questionLabel = _questionLabel;
@synthesize answerTextField = _answerTextField;

@synthesize question = _question;
@synthesize answer = _answer;

@synthesize delegate = _delegate;

- (void)setQuestion:(NSString *)question
{
    _question = question;
    self.questionLabel.text = question;
}

- (void)setAnswer:(NSString *)answer
{
    _answer = answer;
    self.answerTextField.placeholder = answer;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.answer = textField.text;
    if (![textField.text length]) {
        [[self presentingViewController] dismissModalViewControllerAnimated:YES];
    } else {
        [self.delegate askerViewController:self didAskQuestion:self.question andGotAnswer:self.answer];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text length]) {
        [textField resignFirstResponder];
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.questionLabel.text = self.question;
    self.answerTextField.placeholder = self.answer;
    self.answerTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.answerTextField becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setQuestionLabel:nil];
    [self setAnswerTextField:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
