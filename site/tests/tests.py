from selenium import selenium
import time
import unittest
import sys

def get_sel(local=True):
  if local:
    return selenium("localhost", 4444, "*chrome", "http://localhost/")
  else:
    return selenium(
            'saucelabs.com',
            4444,
            """{\
                "username": "zackbloom",\
                "access-key": "7667043c-5df9-49e2-8fb4-231214e37345",\
                "os": "Windows 2003",\
                "browser": "firefox",\
                "browser-version": "7",\
                "name": "Full Test"\
               }""",
           'http://ec2-174-129-177-240.compute-1.amazonaws.com/')

class Tests(unittest.TestCase):
  def setUp(self):
    self.verificationErrors = []
    self.selenium = get_sel(False)
    self.selenium.start()
  
  def tearDown(self):
    self.assertEqual([], self.verificationErrors)
    self.selenium.stop()

  def test_all(self):
    self.selenium.set_timeout("5000")
    self.selenium.open("/")
    self.selenium.wait_for_page_to_load("60000")

    time.sleep(5)
    self._add_to_queue()
    self._regroup()
    self._add_table()
    self._check_in()
    self._clear_table()
    self._delete_from_queue()

  def _add_to_queue(self):
    sel = self.selenium
    sel.click("xpath=//div[@id='queue']//span[.='Add']")
    sel.type("id=party-name", "Tester")
    sel.click("id=party-phone-number")
    sel.type("id=party-size", "5")
    sel.click("id=add-party-submit")
    self.failUnless(sel.is_text_present("Tester"))
    self.failUnless(sel.is_text_present("5"))

  def _add_table(self):
    sel = self.selenium
    sel.click("link=Table Chart")
    sel.click("xpath=//div[@id='tablechart']//span[.='Page Menu']")
    sel.click("link=Edit Table Chart")
    sel.type("id=table-size", "6")
    sel.click("xpath=//label[@for='round']/span/span")
    sel.click("xpath=//div[@id='tablechart']//span['Add Table']")
    sel.type("id=table-label", "A")
    self.failUnless(sel.is_visible("xpath=//div[@class='tablechart']/div/canvas"))
    
    sel.click("xpath=//div[@id='tablechart']//span[.='Page Menu']")
    sel.click("link=Stop Editing")
    
    sel.click("link=Queue")

  def _check_in(self):
    sel = self.selenium
    sel.click("xpath=//ul[@id='queue-list']//a[contains(.,'Tester')]")
    time.sleep(1)

    self.failUnless(sel.is_text_present("Waiting"))
    sel.click("xpath=//div[@id='view-party']//span[.='Check-In']")
    time.sleep(1)

    sel.click("css=.sprite")
    sel.click("xpath=//li[@class='ui-block-b']//span[.='Table Chart']")
    sel.click("css=.sprite")

    self.failUnless(sel.is_text_present("Tester"))
    self.failUnless(sel.is_text_present("Clear Table"))
    self.failUnless(sel.is_text_present("Seated"))
    
  def _clear_table(self):
    sel = self.selenium
    sel.click("link=Table Chart")
    sel.click("xpath=//div[@class='tablechart']/div/canvas")
    sel.click("xpath=//div[@id='view-party']//span[.='Clear Table']")
    sel.click("xpath=//div[@class='tablechart']/div/canvas")
    self.assertNotEqual("#view-party", sel.get_location())

    sel.click("link=Queue")

  def _regroup(self):
    sel = self.selenium
    self.assertEqual(0, sel.get_element_position_left("xpath=//ul[@id='queue-list']/li[contains(.,'Tester')]"))
    sel.click("xpath=//li[@class='ui-block-a']//span[.='Page Menu']")
    sel.click("xpath=//ul[@id='undefined-menu']//a[contains(., 'Grouped By: ')]")
    sel.click("xpath=//ul[@id='undefined-menu']//a[.='Last Name']")
    self.assertNotEqual(0, sel.get_element_position_left("xpath=//ul[@id='queue-list']/li[contains(.,'Tester')]"))

  def _delete_from_queue(self):
    sel = self.selenium
    sel.click("xpath=//ul[@id='queue-list']//a[contains(.,'Tester')]")
    time.sleep(1)
    sel.click("xpath=//div[@id='view-party']//span[.='Delete ']")
    time.sleep(1)
    self.failIf(sel.is_element_present("xpath=//ul[@id='queue-list']//a[contains(.,'Tester')]"))

if __name__ == "__main__":
    unittest.main()
