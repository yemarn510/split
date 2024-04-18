'use client';

import { Steps, Modal, Button, message } from 'antd';
import { ArrowLeftOutlined, ArrowRightOutlined, ExportOutlined, CopyOutlined } from '@ant-design/icons';
import { useState, useEffect } from "react";

import StepOne, { StepOneParams } from "@/components/step-1";
import { Item } from "@/models/item.models";
import StepTwo, { StepTwoParams } from "@/components/step-2";
import { Person } from "@/models/person.models";
import StepThree, { StepThreeParams } from "@/components/step-3";
import { SplitDictionary } from "@/models/split.models";
import StepFour, { StepFourParams } from "@/components/step-4";
import { Result } from "@/models/results.models";

const STEPS = ['Add Items', 'Add People', 'Assign People & Items', 'Review & Split'];

export default function Home() {

  const [currentStep, setCurrentStep] = useState(0);
  const [items, setItems] = useState<Item[]>([]);
  const [people, setPeople] = useState<Person[]>([]);
  const [splitDict, setSplitDict] = useState<SplitDictionary>({});
  const [results, setResults] = useState<Result[]>([]);
  const [saveFriends, setSaveFriends ] = useState<boolean>(false);
  const [openSharePopup, setOpenSharePopup] = useState<boolean>(false);
  const [messageApi, contextHolder] = message.useMessage();
  const steps = STEPS.map(each => ({ title: each }));

  useEffect(() => {
    setCurrentStep(0);
    setItems([ new Item({}) ]);

    const friends = localStorage.getItem('friends') || '';
    if (friends) {
      setPeople(JSON.parse(friends).map((each: Person) => new Person(each)));
      setSaveFriends(true);
    } else {
      setPeople([ new Person({}) ]);
      setSaveFriends(false);
    }
  }, []);

  function goNext(): void {
    switch (currentStep) {
      case 0:
        if (isStepOneValid()) {
          setCurrentStep(1);
        }
        break;
      case 1:
        if (saveFriends) {
          localStorage.setItem('friends', JSON.stringify(people));
        }
        setCurrentStep(2);
        break;
      case 2:
        calculateResults()
        setCurrentStep(3);
        break;
      case 3:
        break;
    }
  }

  function goBack(): void {
    if (currentStep > 0) {
      setCurrentStep(currentStep - 1);
    }
  }

  function isStepOneValid(): boolean {
    const checkingItems = items.map(each => {
      each.isValid();
      return each;
    });
    const isValid = checkingItems.every(each => each.isValid());
    if (isValid) {
      return true;
    }
    setItems([...checkingItems]);
    return false;
  }

  function getCurrentUI(): JSX.Element {
    switch (currentStep) {
      case 0:
        return <StepOne params={stepOneParams} />;
      case 1:
        return <StepTwo params={stepTwoParams} />;
      case 2:
        return <StepThree params={stepThreeParams} />;
      case 3:
        return <StepFour params={stepFourParams} />;
      default:
        return <div>Not Implemented yet!</div>;
    }
  }

  function getButton(): JSX.Element {
    if (currentStep === 3) {
      return <div className={`${currentStep !== 3 && 'hidden' } flex flex-row gap-1 md:gap-3 items-center cursor-pointer md:hover:opacity-50 `}
            onClick={ () => toggleSharePopup() }>
        <div className="w-10 h-10 flex justify-center items-center rounded-full border border-main">
          <ExportOutlined className="text-main" />
        </div>
        <p className="mb-0 w-auto text-main">Share</p>
      </div>
    }
    return <div className={`flex flex-row gap-1 md:gap-3 items-center cursor-pointer md:hover:opacity-50 ${ currentStep === (steps.length - 1) && 'cursor-not-allowed opacity-50'}`}
        onClick={ () => goNext() }>
      <div className="w-10 h-10 flex justify-center items-center rounded-full border border-main">
        <ArrowRightOutlined className="text-main" />
      </div>
      <p className="mb-0 w-auto text-main">Go Next</p>
    </div>
  }

  function toggleSharePopup(): void {
    setOpenSharePopup(!openSharePopup);
  }

  function copyToClipboard(): void {
    const text = results.map(each => `${each.person.name || '-'} - ${each.total.toFixed(2)}`).join('\n');
    navigator.clipboard.writeText(text);
    messageApi.info('Copied !', 2);
  }

  function calculateResults(): void {
    const itemDict: { [key in string]: Item} = {};
    items.forEach((each, index) => itemDict[index.toString()] = each); 

    const personDict: { [key in string]: {
      person: Person,
      result: Result
    }} = {};
    people.forEach((each, index) => {
      personDict[index.toString()] = {
        person: each,
        result: new Result({
          person: each,
          total: 0,
          items: []
        })
      };
    });

    Object.keys(splitDict).forEach((itemIndex) => { // [ {'0': Split Obj, '1': Split Obj} ] -> [0, 1]
      const split = splitDict[itemIndex]; // Split Obj
      const peopleIndexes = Array.from(split.sharingPersonIndex); // [0, 1]
      peopleIndexes.forEach((personIndex) => {
        const person = personDict[personIndex.toString()]; // { person: Person, result: Result }
        const item = itemDict[itemIndex]; // Get Item Object
        item.sharedNumber = peopleIndexes.length;
        person.result.items.push(item); // Add Item to Person's Result
        person.result.total += item.price / peopleIndexes.length; // Add Price to Person's Total
      });
    });

    const results = Object.keys(personDict).map((key) => personDict[key].result);
    setResults(results);
  }

  const stepOneParams: StepOneParams = {
    items,
    setItems,
  };

  const stepTwoParams: StepTwoParams = {
    people,
    setPeople,
    savedFriends: saveFriends,
    setSaveFriends,
  }

  const stepThreeParams: StepThreeParams = {
    items,
    people,
    splitDict,
    setSplitDict,
    setItems,
  }

  const stepFourParams: StepFourParams = {
    results
  }

  return (
    <main className="w-fit m-auto">
      { contextHolder }
      <h1 className="text-center text-main my-5 md:my-10 text-4xl md:text-5xl">
        Let&rsquo;s Split the Bills
      </h1>
      <div className="steps-container hidden md:flex">
        <Steps
          size="small"
          current={currentStep}
          labelPlacement="vertical" 
          items={steps}
        />
      </div>

      <div className="flex flex-row items-center justify-center gap-3 mb-2 md:hidden">
        <div className="rounded-full flex justify-center text-white items-center w-auto h-auto p-2 px-3 bg-main">
          Step:  {currentStep + 1}/{ steps.length }
        </div>
        <h4 className="text-main text-center">
          { steps[currentStep].title }
        </h4>
      </div>


      <div className="main-content">
        { getCurrentUI() }
      </div>
      
      <div className="flex flex-row mt-3 gap-3 md:gap-5 justify-end">
          <div className={`flex flex-row gap-1 md:gap-3 items-center cursor-pointer md:hover:opacity-50 ${ currentStep === 0 && 'cursor-not-allowed opacity-50'}`}
              onClick={ () => goBack() }>
            <p className="mb-0 w-auto text-main">Go Back</p>
            <div className="w-10 h-10 flex justify-center items-center rounded-full border border-main">
              <ArrowLeftOutlined className="text-main" />
            </div>
          </div>

          { getButton() }
        </div>

      <Modal title="Share with your friends"
             footer={null}
             centered
             width={400}
             onCancel={ () => toggleSharePopup() }
             open={openSharePopup} >
        <div className='h-[320px] rounded bg-[#faf1e6] overflow-auto p-5'>
          {
            results.filter( person => person.total > 0 ).map((each, index) => {
              return <h5 className=''
                        key={`total-${index}`}>
                { each.person.name || '-'} - { each.total.toFixed(2) || 0}
              </h5>
            })
          }
        </div>
        <div className='text-center mt-5'>
          <Button
            onClick={ () => copyToClipboard() }
            icon={<CopyOutlined />}>
            Copy To Clipboard
          </Button>
        </div>
      </Modal>
    </main>
  );
}
