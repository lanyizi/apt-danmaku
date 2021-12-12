import ra3.Cafe2_MouseBaseControl;

class ra3.TextInputField extends Cafe2_MouseBaseControl /* implements ICafe2_FocusableControl */
{
    var TextFieldMC: MovieClip;
    var hitRegion: Button;
    var m_textFieldID: Number;
    var m_password: Boolean;
    var m_allowHorzScroll: Boolean;
    var m_charLimit: Number;

    var m_onEnterFunc: Function;

    function TextInputField()
    {
        super();
        this.m_type = "std_mouseTextInputField";
        if (!m_width) {
            m_width = 256;
        }
        if (!m_charLimit) {
            m_charLimit = 256;
        }
    }
    static function getContentsById(fieldId)
    {
        var _loc1_ = new Object();
        loadVariables("QueryGameEngine?TEXT_INPUT_FIELD_CONTENTS?ID=" + String(fieldId),_loc1_);
        var _loc2_ = String(_loc1_.TEXT_INPUT_FIELD_CONTENTS);
        return _loc2_;
    }
    static function getNextTextInputFieldID()
    {
        var _loc1_ = new Object();
        loadVariables("QueryGameEngine?NEXT_TEXT_INPUT_FIELD_ID",_loc1_);
        return Number(_loc1_.NEXT_TEXT_INPUT_FIELD_ID);
    }
    function setWidth(newWidth)
    {
        this.TextFieldMC.dataTF._width = newWidth;
        this.TextFieldMC.BGImgMiddle._x = this.TextFieldMC.BGImgLeft._width;
        this.TextFieldMC.BGImgMiddle._width = newWidth - this.TextFieldMC.BGImgRight._width - this.TextFieldMC.BGImgLeft._width;
        this.TextFieldMC.BGImgRight._x = newWidth - this.TextFieldMC.BGImgRight._width;
        this.hitRegion._width = newWidth;
    }
    function onLoad()
    {
        this.m_textFieldID = getNextTextInputFieldID();
        var _loc3_ = !this.m_password ? "0" : "1";
        var _loc4_ = !m_allowHorzScroll ? "0" : "1";
        fscommand("CallGameFunction","%CreateTextInputField?Name=" + this + "|ID=" + this.m_textFieldID + "|Password=" + _loc3_ + "|CharLimit=" + m_charLimit + "|AllowScroll=" + _loc4_);
        this.TextFieldMC.dataTF.text = "$EDITABLE_TEXT_" + this.m_textFieldID;
        this.TextFieldMC.dataTF.setTextFormat(_global.std_config.textBox_textFormat_unhighlight);
        hitRegion.onRollOver = this.bind0(this,this.mouseEventTextFieldRollover);
        hitRegion.onRollOut = this.bind0(this,this.mouseEventTextFieldRollOut);
        hitRegion.onPress = this.bind0(this,this.mouseEventTextFieldPress);
        hitRegion.onRelease = this.bind0(this,this.mouseEventTextFieldRelease);
        hitRegion.onReleaseOutside = this.bind0(this,this.mouseEventTextFieldReleaseOutside);
        this.setWidth(m_width);
        this.commonInit();

        this.show();
    }
    function onUnload()
    {
        fscommand("CallGameFunction","%BlurTextInputField?ID=" + this.m_textFieldID);
        fscommand("CallGameFunction","%DestroyTextInputField?ID=" + this.m_textFieldID);
    }
    function getContents()
    {
        return getContentsById(this.m_textFieldID);
    }
    function setContents(string)
    {
        fscommand("CallGameFunction","%SetTextInputFieldContents?ID=" + this.m_textFieldID + "|String=" + string);
    }
    function takeFocus()
    {
        this.m_objFM.setFocusToControl(this);
        fscommand("CallGameFunction","%FocusTextInputField?ID=" + this.m_textFieldID);
    }
    function highlight()
    {
        this.gotoAndPlay("_highlight");
        this.takeFocus();
    }
    function unhighlight()
    {
        this.gotoAndPlay("_unhighlight");
        fscommand("CallGameFunction","%BlurTextInputField?ID=" + this.m_textFieldID);
    }
    function enableGUI()
    {
        this.gotoAndPlay("_unselect");
    }
    function disableGUI()
    {
        this.gotoAndPlay("_disable");
    }
    function rollover()
    {
    }
    function rollout()
    {
    }
    function setOnEnterFunction(onEnterFunc)
    {
        this.m_onEnterFunc = onEnterFunc;
    }
    function executeOnEnterFunction()
    {
        if(this.m_onEnterFunc != undefined)
        {
            this.m_onEnterFunc();
        }
    }
    function mouseEventTextFieldRollover()
    {
        this.rollover();
    }
    function mouseEventTextFieldRollOut()
    {
        this.rollout();
    }
    function mouseEventTextFieldPress()
    {
        this.m_objFM.setFocusToControl(this);
        fscommand("CallGameFunction","%OnTextInputFieldMouseDown?ID=" + this.m_textFieldID + "|x=" + this._xmouse + "|y=" + this._ymouse);
        this.onMouseMove = this.bind0(this,this.mouseEventTextFieldMouseMove);
    }
    function mouseEventTextFieldRelease()
    {
        fscommand("CallGameFunction","%OnTextInputFieldMouseUp?ID=" + this.m_textFieldID + "|x=" + this._xmouse + "|y=" + this._ymouse);
        this.onMouseMove = null;
    }
    function mouseEventTextFieldReleaseOutside()
    {
        this.mouseEventTextFieldRelease();
        this.mouseEventTextFieldRollOut();
    }
    function mouseEventTextFieldMouseMove()
    {
        fscommand("CallGameFunction","%OnTextInputFieldMouseMove?ID=" + this.m_textFieldID + "|x=" + this._xmouse + "|y=" + this._ymouse);
    }
}