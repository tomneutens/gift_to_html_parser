var peg = require("pegjs");
var fs = require('fs/promises');
var assert = require('assert');
var parseString = require("../parser.js").parseString





describe('True false questions', function() {
    let grammar = "";
    before(async function(){
        grammar = await fs.readFile('./grammars/gift_to_html_grammar.pegjs', 'utf8');
    });

    it('True false gift question without feedback, title or id results in correct html', function() {
        let test_question = "Is this True? {T}";
        let result = parseString(grammar, test_question)
        let expected = '<div class="gift_question" id="gift_question_0"><div class="gift_question_body_stem1"><span class="gift_question_text">Is this True? </span></div><div class="gift_question_body_answers"><div class="gift_tf_answer" data-gift-tf-answer="true"></div></div></div>'
        assert.equal(result, expected);
    });

    it('True false gift question without feedback, title with id and tags results in correct html', function() {
        let test_question = '//  [id:tf_001] [tag:tf_question] [tag:set 1]\nIs this True? {T}';
        let result = parseString(grammar, test_question)
        let expected = '<div class="gift_question" id="gift_question_tf_001"><div class="gift_question_body_stem1"><span class="gift_question_text">Is this True? </span></div><div class="gift_question_body_answers"><div class="gift_tf_answer" data-gift-tf-answer="true"></div></div></div>'
        assert.equal(result, expected);
    });

    it('True false gift question with feedback without title, id and tags results in correct html', function() {
        let test_question = 'Is this True?{T#42is the Ultimate Answer.#You gave the right answer.}';
        let result = parseString(grammar, test_question)
        let expected = '<div class="gift_question" id="gift_question_0"><div class="gift_question_body_stem1"><span class="gift_question_text">Is this True?</span></div><div class="gift_question_body_answers"><div class="gift_tf_answer" data-gift-tf-answer="true"></div><div class="gift_question_feedback gift_feedback gift_feedback_wrong_answer"><span class="gift_question_feedback_text">42is the Ultimate Answer.</span></div><div class="gift_question_feedback gift_feedback gift_feedback_right_answer"><span class="gift_question_feedback_text">You gave the right answer.</span></div></div></div>'
        assert.equal(result, expected);
    });

    it('True false gift question with feedback and global feedback without title, id and tags results in correct html', function() {
        let test_question = 'Is this True?{T #42is the Ultimate Answer.#You gave the right answer. #### This is some global feedback.}';
        let result = parseString(grammar, test_question)
        let expected = '<div class="gift_question" id="gift_question_0"><div class="gift_question_body_stem1"><span class="gift_question_text">Is this True?</span></div><div class="gift_question_body_answers"><div class="gift_tf_answer" data-gift-tf-answer="true"></div><div class="gift_question_feedback gift_feedback gift_feedback_wrong_answer"><span class="gift_question_feedback_text">42is the Ultimate Answer.</span></div><div class="gift_question_feedback gift_feedback gift_feedback_right_answer"><span class="gift_question_feedback_text">You gave the right answer. </span></div><div class="gift_global_feedback gift_feedback">This is some global feedback.</div></div></div>'
        assert.equal(result, expected);
    });
    
    it('True false gift question with title in correct html', function() {
        let test_question = '::First true or false question\n::Is this True?{T}';
        let result = parseString(grammar, test_question)
        let expected = '<div class="gift_question" id="gift_question_0"><h2 class="gift_question_title">First true or false question\n</h2><div class="gift_question_body_stem1"><span class="gift_question_text">Is this True?</span></div><div class="gift_question_body_answers"><div class="gift_tf_answer" data-gift-tf-answer="true"></div></div></div>'
        assert.equal(result, expected);
    });

});


describe('Multiple choise answers', function() {
    let grammar = "";
    before(async function(){
        grammar = await fs.readFile('./grammars/gift_to_html_grammar.pegjs', 'utf8');
    });

    it('MC gift question without feedback, title or id results in correct html', function() {
        let test_question = `Since {
~495 AD
=1066 AD
~1215 AD
~ 43 AD
} the town of Hastings England has been "famous with visitors".`;
        let result = parseString(grammar, test_question)
        let expected = `<div class="gift_question" id="gift_question_0"><div class="gift_question_body_stem1"><span class="gift_question_text">Since </span></div><div class="gift_question_body_answers"><div class="gift_mc_answer_options"><div class="gift_mc_answer_choice" data-gift-mc-answer-choise-weight="null"" data-gift-mc-answer-correct="false"" id="gift_choice_0">495 AD
</div><div class="gift_mc_answer_choice" data-gift-mc-answer-choise-weight="null"" data-gift-mc-answer-correct="true"" id="gift_choice_1">1066 AD
</div><div class="gift_mc_answer_choice" data-gift-mc-answer-choise-weight="null"" data-gift-mc-answer-correct="false"" id="gift_choice_2">1215 AD
</div><div class="gift_mc_answer_choice" data-gift-mc-answer-choise-weight="null"" data-gift-mc-answer-correct="false"" id="gift_choice_3">43 AD
</div></div></div><div class="gift_question_body_stem2"><span class="gift_question_text">the town of Hastings England has been "famous with visitors".</span></div></div>`
        assert.equal(result, expected);
    });

    it('MC gift question without feedback with weights, title or id results in correct html', function() {
        let test_question = `What two people are entombed in Grant's tomb? {
~%-100%No one
~%50%Grant
~%50%Grant's wife
~%-100%Grant's father
}`;
        let result = parseString(grammar, test_question)
        let expected = `<div class="gift_question" id="gift_question_0"><div class="gift_question_body_stem1"><span class="gift_question_text">What two people are entombed in Grant's tomb? </span></div><div class="gift_question_body_answers"><div class="gift_mc_answer_options"><div class="gift_mc_answer_choice" data-gift-mc-answer-choise-weight="-100"" data-gift-mc-answer-correct="false"" id="gift_choice_0">No one
</div><div class="gift_mc_answer_choice" data-gift-mc-answer-choise-weight="50"" data-gift-mc-answer-correct="false"" id="gift_choice_1">Grant
</div><div class="gift_mc_answer_choice" data-gift-mc-answer-choise-weight="50"" data-gift-mc-answer-correct="false"" id="gift_choice_2">Grant's wife
</div><div class="gift_mc_answer_choice" data-gift-mc-answer-choise-weight="-100"" data-gift-mc-answer-correct="false"" id="gift_choice_3">Grant's father
</div></div></div></div>`
        assert.equal(result, expected);
    });

    it('MC gift question with id, title and feedback correct html', function() {
        let test_question = ` // [id:question_1] question: 1 name: Grants tomb
::Grants tomb::Who is buried in Grant's tomb in New York City? {
=Grant
~No one
#Was true for 12 years, but Grant's remains were buried in the tomb in 1897
~Napoleon
#He was buried in France
~Churchill
#He was buried in England
~Mother Teresa
#She was buried in India
}`;
        let result = parseString(grammar, test_question)
        let expected = `<div class="gift_question" id="gift_question_question_1"><h2 class="gift_question_title">Grants tomb</h2><div class="gift_question_body_stem1"><span class="gift_question_text">Who is buried in Grant's tomb in New York City? </span></div><div class="gift_question_body_answers"><div class="gift_mc_answer_options"><div class="gift_mc_answer_choice" data-gift-mc-answer-choise-weight="null"" data-gift-mc-answer-correct="true"" id="gift_choice_0">Grant
</div><div class="gift_mc_answer_choice" data-gift-mc-answer-choise-weight="null"" data-gift-mc-answer-correct="false"" id="gift_choice_1">No one
</div><div class="gift_feedback gift_question_feedback"><span class="gift_question_feedback_text">Was true for 12 years, but Grant's remains were buried in the tomb in 1897
</span></div><div class="gift_mc_answer_choice" data-gift-mc-answer-choise-weight="null"" data-gift-mc-answer-correct="false"" id="gift_choice_2">Napoleon
</div><div class="gift_feedback gift_question_feedback"><span class="gift_question_feedback_text">He was buried in France
</span></div><div class="gift_mc_answer_choice" data-gift-mc-answer-choise-weight="null"" data-gift-mc-answer-correct="false"" id="gift_choice_3">Churchill
</div><div class="gift_feedback gift_question_feedback"><span class="gift_question_feedback_text">He was buried in England
</span></div><div class="gift_mc_answer_choice" data-gift-mc-answer-choise-weight="null"" data-gift-mc-answer-correct="false"" id="gift_choice_4">Mother Teresa
</div><div class="gift_feedback gift_question_feedback"><span class="gift_question_feedback_text">She was buried in India
</span></div></div></div></div>`
        assert.equal(result, expected);
    });

   
});