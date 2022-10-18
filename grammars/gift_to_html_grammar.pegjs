// All these helper functions are available inside of actions 
{
  let currentCategory = null;
  let matchQuestionMatchId = 0;
  var questionId = null;
  let autoQuestionId = 0;
  let autoChoiseId = 0;
  var questionTags = null;
  var defaultFormat = "moodle"; // default format - the GIFT specs say [moodle] is default, but not sure what that means for other applications
  var format = defaultFormat;
  function processAnswers(question, answers) {
    question.globalFeedback = answers.globalFeedback;
    switch(question.type) {
      case "TF":
        question.isTrue = answers.isTrue;
        question.incorrectFeedback = answers.feedback[1];
        question.correctFeedback = answers.feedback[2];
        break;
      case "MC":
      case "Numerical":
      case "Short":
        question.choices = answers.choices;
        break;
      case "Matching":
        question.matchPairs = answers.matchPairs;
        break;
    }
    // check for MC that's actually a short answer (all correct answers)
    if (question.type == "MC" && areAllCorrect(question.choices)) {
      question.type = "Short";
    }
    question.id = questionId;
    question.tags = questionTags;
    return question;
  }
  function areAllCorrect(choices) {
    var allAreCorrect = true;
    for (var i = 0; i < choices.length; i++) {
      allAreCorrect &= choices[i].isCorrect;
    }
    return allAreCorrect;
  }
  function removeNewLinesDuplicateSpaces(text) {
    text = text.replace(/[\n\r]/g,' '); // replace newlines with spaces
    return text.replace(/\s\s+/g,' '); 
  }
  function setLastQuestionTextFormat(fmt) {
    format = fmt;
  }
  function getLastQuestionTextFormat() {
    return format;
  }
  function resetLastQuestionTextFormat() {
    format = defaultFormat;
  }
}

GIFTQuestions
  = questions:(Category / Description / Question)+ _ __ { 
    let questions_html =  questions.join("");
    console.log("GIFTQuestions")
    console.log(questions_html)
    return questions_html;
   }

Category "Category"
  = ResetIdsTags __ '$' 'CATEGORY:' _ cat:CategoryText QuestionSeparator {
    let tags = "";
    if (cat !== currentCategory && currentCategory !== null){
      tags += "</div>" // Close the previous category
    }
    tags += `<div class="gift_category" data-gift-category="${cat}">` // Add an opening tag for the new category
    //return tags
    console.log("Category")
    console.log("''")
    return "" // For now, no category support
  }

Description "Description"
  = ResetIdsTags __
    tagInfo: TagComment*
    title:QuestionTitle? _
    text:QuestionStem
    QuestionSeparator
    { 
      let tags_html = questionTags.join(";");
      let id = 0;
      if (questionId !== null) {
        id = questionId;
      } else {
        id = autoQuestionId;
        autoQuestionId++;
      }
      let description_html = `<div class="gift_description" id="gift_question_${id}">`
      description_html += (title) ? `${title}` : ""
      description_html += (text) ? `<div class="gift_question_body">${text}</div>` : ""
      description_html += (tags_html) ?`<div class="gift_tags">${tags_html}</div>` : ""
      description_html += `</div>`
      resetLastQuestionTextFormat(); 
      questionId = null; questionTags = null;
      console.log("Description")
      console.log(description_html)
      return description_html }

Question
  = ResetIdsTags __
    tagInfo:TagComment?
    title:QuestionTitle? _
    stem1:QuestionStem? _ 
    '{' _
    answers:(MatchingAnswers / TrueFalseAnswer / MCAnswers / NumericalAnswerType / SingleCorrectShortAnswer / EssayAnswer ) _
    '}' _
    stem2:(
      Comment / 
      QuestionStem)?
    QuestionSeparator
  {
    let id = 0;
    if (questionId !== null) {
      id = questionId;
    } else {
      id = autoQuestionId;
      autoQuestionId++;
    }
    let question_html = `<div class="gift_question" id="gift_question_${id}">`
      question_html += (title) ? `${title}` : ""
      question_html += (stem1) ? `<div class="gift_question_body_stem1">${stem1}</div>` : ""
      question_html += (answers) ? `<div class="gift_question_body_answers">${answers}</div>` : ""
      question_html += (stem2) ? `<div class="gift_question_body_stem2">${stem2}</div>` : ""
      question_html += `</div>`
    resetLastQuestionTextFormat();
    console.log("Question")
    console.log(question_html)
    return question_html;
  }

MatchingAnswers "{= match1 -> Match1\n...}"
  = matchPairs:Matches _ globalFeedback:GlobalFeedback? _
  {
    let combined_matches = matchPairs.join("");
    let matches_html = `<div class="gift_matches">${combined_matches}</div>`
    matches_html += (globalFeedback) ? `<div class="gift_global_feedback gift_feedback">${globalFeedback}</div>` : "";
    console.log("MatchingAnswers")
    console.log(matches_html)
    return matches_html}

Matches "matches"
  = matchPairs:(Match)+  { return matchPairs }
  
Match "match"
  = _ '=' _ left:MatchRichText? _ '->' _ right:PlainText _ 
    { 
      let match_html = `
      <div class="gift_match_pair_match_option gift_match_pair_source" data-gift-match-question-match-id="${matchQuestionMatchId}">${left}</div>
      <div class="gift_match_pair_match_option gift_match_pair_destination" data-gift-match-question-match-id="${matchQuestionMatchId}">${right}</div>
      `
      console.log("Match")
      console.log(match_html)
      return match_html 
    } 

///////////
TrueFalseAnswer "{T} or {F} or {TRUE} or {FALSE}"
  = isTrue:TrueOrFalseType _ 
    feedback:(_ Feedback? Feedback?) _
    globalFeedback:GlobalFeedback?
  { 
    console.log("------------------------------------------------------------>>>> " + feedback + "\n" + feedback[1] + "\n" + feedback[2])
    let tf_html = `<div class="gift_tf_answer" data-gift-tf-answer="${isTrue}"></div>`;
    tf_html += (feedback[1] && feedback[1] != "") ? `<div class="gift_question_feedback gift_feedback gift_feedback_wrong_answer">${feedback[1]}</div>`: "";
    tf_html += (feedback[2] && feedback[2] != "") ? `<div class="gift_question_feedback gift_feedback gift_feedback_right_answer">${feedback[2]}</div>`: "";
    tf_html += (globalFeedback) ? `<div class="gift_global_feedback gift_feedback">${globalFeedback}</div>` : "";
    
    console.log("TrueFalseAnswer")
    console.log(tf_html)
    return tf_html }
  
TrueOrFalseType 
  = isTrue:(TrueType / FalseType) { return isTrue }
  
TrueType
  = ('TRUE' / 'T') {return true}

FalseType
  = ('FALSE' / 'F') {return false}

////////////////////
MCAnswers "{=correct choice ~incorrect choice ... }"
  = choices:Choices _ 
    globalFeedback:GlobalFeedback? _
  {
    let mc_html = `<div class="gift_mc_answer_options">${choices}</div>`
    mc_html += globalFeedback ? `<div class="gift_feedback gift_global_feedback">${globalFeedback}</div>` : ""
    autoChoiseId = 0;
    return mc_html }

Choices "Choices"
  = choices:(Choice)+ { return choices.join(""); }
 
Choice "Choice"
  = _ choice:([=~] _ Weight? _ RichText) feedback:Feedback? _ 
    { var wt = choice[2];
      var txt = choice[4];
      let choice_html = 
      `<div class="gift_mc_answer_choice" data-gift-mc-answer-choise-weight="${wt}"" data-gift-mc-answer-correct="${(choice[0] == '=')}"" id="gift_choice_${autoChoiseId}">${txt}</div>`
      choice_html += feedback ? `<div class="gift_feedback gift_question_feedback">${feedback}</div>` : ""
      autoChoiseId++
      return choice_html } 

Weight "(weight)"
  = '%' percent:([-]? PercentValue) '%' { return parseFloat(percent.join('')) }
  
PercentValue "(percent)"
  = '100' / [0-9][0-9]?[.]?[0-9]*  { return text() }

Feedback "(feedback)" 
  = '#' !'###' _ feedback:RichText? { 
    return (feedback || feedback == "") ? `<span class="gift_question_feedback_text">${feedback}</span>` : null
    }

////////////////////
EssayAnswer "Essay question { ... }"
  = '' _
    globalFeedback:GlobalFeedback? _ 
  { 
    let essay_answer_html = `<div class="gift_essay_answer"><textarea class="gift_essay_answer_input"></textarea></div>`
    essay_answer_html += globalFeedback ? `<div class="gift_feedback gift_global_feedback">${globalFeedback}</div>` : ""
    console.log("EssayAnswer")
    console.log(essay_answer_html)
    return essay_answer_html; }

///////////////////
SingleCorrectShortAnswer "Single short answer { ... }"
  = answer:RichText _ 
    feedback:Feedback? _ 
    globalFeedback:GlobalFeedback? _
  { 
    let single_correct_short_answer_html = `<div class="gift_single_correct_short_answer">${answer}</div>`
    single_correct_short_answer_html += feedback ? `<div class="gift_question_feedback gift_feedback">${feedback}</div>` : ""
    single_correct_short_answer_html += globalFeedback ? `<div class="gift_global_feedback gift_feedback">${globalFeedback}</div>` : ""
    
    console.log("SingleCorrectShortAnswer")
    console.log(single_correct_short_answer_html)
    return single_correct_short_answer_html }

///////////////////
NumericalAnswerType "{#... }" // Number ':' Range / Number '..' Number / Number
  = '#' _
    numericalAnswers:NumericalAnswers _ 
    globalFeedback:GlobalFeedback? 
  { 
    autoChoiseId = 0;
    console.log("-------------------------->>>>>>" + numericalAnswers);
    let answers_html = numericalAnswers
    let numerical_answer_type_html = `<div class="gift_numerical_answers">${answers_html}</div>`
    numerical_answer_type_html += globalFeedback ? `<div class="gift_global_feedback gift_feedback">${globalFeedback}</div>` : ""
    
    console.log("NumericalAnswerType")
    console.log(numerical_answer_type_html)
    return numerical_answer_type_html; }

NumericalAnswers "Numerical Answers"
  = MultipleNumericalChoices / SingleNumericalAnswer

MultipleNumericalChoices "Multiple Numerical Choices"
  = choices:(NumericalChoice)+ { return choices.join(""); }

NumericalChoice "Numerical Choice"
  = _ choice:([=~] Weight? SingleNumericalAnswer?) _ feedback:Feedback? _ 
    { var symbol = choice[0];
      var wt = choice[1];
      var txt = choice[2];
      console.log("TXT ---------------------> " + txt)
      let numerical_choise_html = `<div class="gift_numerical_answer_choise" data-gift-mc-answer-choise-weight="${wt}" data-gift-mc-answer-correct="${(symbol == '=')}" id="gift_choice_${autoChoiseId}">${txt}</div>`
      numerical_choise_html += feedback ? `<div class="gift_question_feedback gift_feedback">${feedback}</div>` : ""
      console.log("NumericalChoice")
      console.log(numerical_choise_html)
      return numerical_choise_html } 

SingleNumericalAnswer "Single numeric answer"
  = NumberWithRange / NumberHighLow / NumberAlone

NumberWithRange "(number with range)"
  = number:Number ':' range:Number 
  { console.log("NumberWithRange")
    console.log(`<span class="gift_range_answer" data-gift-range="${range}" data-gift-range-number="${number}">${number}</span>`)
    return `<span class="gift_range_answer" data-gift-range="${range}" data-gift-range-number="${number}">${number}</span>`}

NumberHighLow "(number with high-low)"
  = numberLow:Number '..' numberHigh:Number 
  { console.log("NumberHighLow")
    console.log(`<span class="gift_range_high_low" data-gift-range-low="${numberLow}" data-gift-range-high="${numberHigh}"></span>`)
    return `<span class="gift_range_high_low" data-gift-range-low="${numberLow}" data-gift-range-high="${numberHigh}"></span>` }

NumberAlone "(number answer)"
  = number:Number
  { return number }  

//////////////
QuestionTitle ":: Title ::"
  = '::' title:TitleText+ '::' { return title.join('').length == 0 ? "" : `<h2 class="gift_question_title">${title.join('')}</h2>`; }
  
QuestionStem "Question stem" 
  = stem:RichText 
    { 
      return `<span class="gift_question_text">${stem}</span>` // TODO: read format and translate to html for now assume plain text 
    }

QuestionSeparator "(blank lines separator)"
  = BlankLines  
    / EndOfLine? EndOfFile

BlankLines "(blank lines)"
  = EndOfLine BlankLine+

BlankLine "blank line"
  = Space* EndOfLine

TitleText "(Title text)"
  = !'::' t:(EscapeSequence / UnescapedChar) {return t}

TextChar "(text character)"
  = (UnescapedChar / EscapeSequence / EscapeChar)

MatchTextChar "(text character)"
  = (UnescapedMatchChar / EscapeSequence / EscapeChar)

Format "format"
  = '[' format:('html' /
                'markdown' /
                'plain' / 
                'moodle') 
    ']' {return "html"}

EscapeChar "(escape character)"
  = '\\' 

EscapeSequence "escape sequence" 
  = EscapeChar 
    sequence:( 
      EscapeChar 
      / ":" 
      / "~" 
      / "="
      / "#"
      / "["
      / "]"
      / "{"
      / "}" )
  { return sequence }
 
UnescapedChar ""
  = !(EscapeSequence / ControlChar / QuestionSeparator) . {return text()}

UnescapedMatchChar ""
  = !(EscapeSequence / ControlChar / '->' / QuestionSeparator) . {return text()}

ControlChar 
  = '=' / '~' / "#" / '{' / '}' / '\\' / ':'

MatchRichText "(formatted text excluding '->'"
  = format:Format? _ txt:MatchTextChar+ { return txt.join('').replace(/\r\n/g,'\n') }


RichText "(formatted text)"
  = format:Format? _ txt:TextChar+ { return txt.join('').replace(/\r\n/g,'\n') }// avoid failing tests because of Windows line breaks 

PlainText "(unformatted text)"
  = txt:TextChar+ { return removeNewLinesDuplicateSpaces(txt.join('').trim())} 

CategoryText "(category text)"
  = txt:(!EndOfLine .)* &(EndOfLine / EndOfFile) { return txt.flat().join('') } 

// folllowing inspired by http://nathansuniversity.com/turtle1.html
Number
    = chars:[0-9]+ frac:NumberFraction?
        { return parseFloat(chars.join('') + frac); }

NumberFraction
    = "." !"." chars:[0-9]*
        { return "." + chars.join(''); }

GlobalFeedback
    = '####' _ rt:RichText _ {return rt;}

_ "(single line whitespace)"
  = (Space / EndOfLine !BlankLine)*

__ "(multiple line whitespace)"
  = (TagComment / EndOfLine / Space )*

ResetIdsTags 
  = &' '*     // useless match to reset any previously parsed tags/ids
    {questionId = null; questionTags = null}

Comment "(comment)"
  = '//' p:([^\n\r]*)
 {return `<!-- ${p} -->`}


TextUntilNewLineTerminator
 = x:(&HaveNewLineTerminatorAhead .)* { return x.map(y => y[1]) }

HaveNewLineTerminatorAhead
 = . (!"\n" .)* "\n"

TagComment "(comment)"
  = '//' p:([^\n\r]*)
  {
    var comment = p.join("");
    // use a regex like the Moodle parser
    var idIsFound = comment.match(/\[id:([^\x00-\x1F\x7F]+?)]/); 
    if(idIsFound) {
        questionId = idIsFound[1].trim().replace('\\]', ']');
    }
    
    // use a regex like the Moodle parser
    var tagMatches = comment.matchAll(/\[tag:([^\x00-\x1F\x7F]+?)]/g);
    Array.from(
      comment.matchAll(/\[tag:([^\x00-\x1F\x7F]+?)]/g), 
                       function(m) { return m[1] })
              .forEach(function(element) {
                if(!questionTags) questionTags = [];
                questionTags.push(element);
              });
    return null // hacking, must "reset" values each time a partial match happens
  }

Space "(space)"
  = ' ' / '\t'
EndOfLine "(end of line)"
  = '\r\n' / '\n' / '\r'
EndOfFile 
  = !. { return "EOF"; }
