terraform {
  required_providers {
    genesyscloud = {
      source = "mypurecloud/genesyscloud"
    }
  }
}

provider "genesyscloud" {
  sdk_debug = true
}

resource "genesyscloud_user" "sf_joesmith" {
  email           = "joe.smith@simplefinancial.com"
  name            = "Joe Smith"
  password        = "b@Zinga1972"
  state           = "active"
  department      = "IRA"
  title           = "Agent"
  acd_auto_answer = true
  addresses {

    phone_numbers {
      number     = "+19205551212"
      media_type = "PHONE"
      type       = "MOBILE"
    }
  }
  employer_info {
    official_name = "Joe Smith"
    employee_id   = "12345"
    employee_type = "Full-time"
    date_hire     = "2021-03-18"
  }
}

resource "genesyscloud_user" "sf_suesmith" {
  email           = "sue.smith@simplefinancial.com"
  name            = "sue Smith"
  password        = "b@Zinga1972"
  state           = "active"
  department      = "IRA"
  title           = "Agent"
  acd_auto_answer = true
  addresses {

    phone_numbers {
      number     = "+19205551212"
      media_type = "PHONE"
      type       = "MOBILE"
    }
  }
  employer_info {
    official_name = "Sue Smith"
    employee_id   = "67890"
    employee_type = "Full-time"
    date_hire     = "2021-03-18"
  }
}

resource "genesyscloud_routing_queue" "queue_iratest" {
  name                     = "Simple Financial IRA testqueue"
  description              = "Simple Financial IRA questions and answers test"
  acw_wrapup_prompt        = "MANDATORY_TIMEOUT"
  acw_timeout_ms           = 300000
  skill_evaluation_method  = "BEST"
  auto_answer_only         = true
  enable_transcription     = true
  enable_manual_assignment = true

  members {
    user_id  = genesyscloud_user.sf_joesmith.id
    ring_num = 1
  }
}

resource "genesyscloud_routing_queue" "queue_K401test" {
  name                     = "Simple Financial 401K testqueue"
  description              = "Simple Financial 401K questions and answers"
  acw_wrapup_prompt        = "MANDATORY_TIMEOUT"
  acw_timeout_ms           = 300000
  skill_evaluation_method  = "BEST"
  auto_answer_only         = true
  enable_transcription     = true
  enable_manual_assignment = true
  members {
    user_id  = genesyscloud_user.sf_joesmith.id
    ring_num = 1
  }

  members {
    user_id  = genesyscloud_user.sf_suesmith.id
    ring_num = 1
  }
}

resource "genesyscloud_flow" "mysimpleflowMSL" {
  filepath = "./SimpleFinancialIvrMSL_v2-0.yaml"
  file_content_hash = filesha256("./SimpleFinancialIvrMSL_v2-0.yaml") 
}


resource "genesyscloud_telephony_providers_edges_did_pool" "mygcv_number" {
  start_phone_number = "+18885422729"
  end_phone_number   = "+18885422729"
  description        = "GCV Number for inbound calls"
  comments           = "Additional comments"
}

resource "genesyscloud_architect_ivr" "mysimple_ivr" {
  name               = "A simple IVRMSL"
  description        = "A sample IVR configuration"
  dnis               = ["+18885422729", "+18885422729"]
  open_hours_flow_id = genesyscloud_flow.mysimpleflow.id
  depends_on         = [
    genesyscloud_flow.mysimpleflowMSL,
    genesyscloud_telephony_providers_edges_did_pool.mygcv_number
  ]
}

