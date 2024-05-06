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
import LoginPopup from '@/components/login-popup';
import { calculateResults, someStepsAreEmpty } from '@/functions/common.functions';
import getButton from '@/components/next-button';

const STEPS = ['Add People', 'Add Items', 'Assign People & Items', 'Review & Split'];

export default function Home() {

  const [currentStep, setCurrentStep] = useState(0);
  const [items, setItems] = useState<Item[]>([]);
  const [people, setPeople] = useState<Person[]>([]);
  const [splitDict, setSplitDict] = useState<SplitDictionary>({});
  const [results, setResults] = useState<Result[]>([]);
  const [saveFriends, setSaveFriends ] = useState<boolean>(false);

  const steps: { title: string}[] = STEPS.map(each => ({ title: each }));

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
    if (goNextButtonDisabled()) {
      return;
    }

    switch (currentStep) {
      case 0:
        saveFriends ?
          localStorage.setItem('friends', JSON.stringify(people)) :
          localStorage.removeItem('friends');
        setCurrentStep(1);
        break;
      case 1:
        if (isStepTwoValid()) {
          setCurrentStep(2);
        }
        break;
      case 2:
        if (someStepsAreEmpty(splitDict)) {
          return;
        }
        const results = calculateResults(items, people, splitDict);
        setResults(results);
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

  function isStepTwoValid(): boolean {
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

  function goNextButtonDisabled(): boolean {
      switch (currentStep) {
        case 0:
          return people.length === 0;
        case 1:
          return items.length === 0;
        case 2:
          return someStepsAreEmpty(splitDict);
        case 3:
          return false;
      }
    return false;
  }

  const stepTwoParams: StepTwoParams = {
    items,
    setItems,
    people,
  };

  const stepOneParams: StepOneParams = {
    people,
    setPeople,
    savedFriends: saveFriends,
    setSaveFriends,
    items, 
    setItems,
  }

  const stepThreeParams: StepThreeParams = {
    items,
    people,
    splitDict,
    setSplitDict,
    setItems,
  }

  const stepFourParams: StepFourParams = {
    results,
    setResults,
  }

  return (
    <main className="w-fit m-auto">
      <div className='flex flex-row my-5 md:my-10'>
        <div className='w-10/12'> 
          <h1 className="text-center text-main text-4xl md:text-5xl">
            Let&rsquo;s Split the Bills
          </h1>
        </div>  
        <div className='w-1/12 flex items-center'>
          <LoginPopup setPeople={setPeople} />
        </div>
      </div> 
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

          { getButton(currentStep, results, steps, goNextButtonDisabled, goNext) }
        </div>
    </main>
  );
}