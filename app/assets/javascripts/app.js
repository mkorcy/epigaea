// Popover menu to select the type of work when starting a deposit
Hyrax.selectWorkType = function () {
        var TuftsSelectWorkType = require('tufts/select_work_type')
        $("[data-behavior=select-work]").each(function () {
            new TuftsSelectWorkType($(this))
        })
}
